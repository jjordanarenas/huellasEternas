//
//  MemorialOrderService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 17/12/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

struct MemorialOrderItem {
    let memorialId: String
    let relationship: Relationship
    let isArchived: Bool
}

enum Relationship: String {
    case owned
    case joined
}

final class MemorialOrderService {

    private let db = Firestore.firestore()

    /// Devuelve el orden del usuario: [(memorialId, relationship)]
    func fetchOrder() async throws -> [MemorialOrderItem] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let snap = try await db
            .collection("users")
            .document(uid)
            .collection("memorialOrder")
            .order(by: "sortIndex", descending: false)
            .getDocuments()

        return snap.documents.compactMap { doc in
            let data = doc.data()
            guard
                let relRaw = data["relationship"] as? String,
                let rel = Relationship(rawValue: relRaw)
            else { return nil }

            let archived = data["isArchived"] as? Bool ?? false
            return MemorialOrderItem(memorialId: doc.documentID, relationship: rel, isArchived: archived)
        }
    }

    /// Upsert: fija sortIndex y relationship de un memorial en el orden del usuario
    func upsert(memorialId: String, relationship: Relationship, sortIndex: Int) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        try await db
            .collection("users")
            .document(uid)
            .collection("memorialOrder")
            .document(memorialId)
            .setData([
                "relationship": relationship.rawValue,
                "sortIndex": sortIndex,
                "isArchived": false,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
    }

    /// Guarda TODO el orden (batch) tras un drag&drop.
    func saveFullOrder(memorialIdsInOrder: [String], relationshipById: [String: Relationship]) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let batch = db.batch()
        let baseRef = db.collection("users").document(uid).collection("memorialOrder")

        for (index, id) in memorialIdsInOrder.enumerated() {
            let rel = relationshipById[id] ?? .owned
            let ref = baseRef.document(id)
            batch.setData([
                "relationship": rel.rawValue,
                "sortIndex": index,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: ref, merge: true)
        }

        try await batch.commit()
    }

    func setArchived(memorialId: String, isArchived: Bool) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref = db
            .collection("users")
            .document(uid)
            .collection("memorialOrder")
            .document(memorialId)

        var data: [String: Any] = [
            "isArchived": isArchived,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        // Solo guardamos archivedAt al archivar
        if isArchived {
            data["archivedAt"] = FieldValue.serverTimestamp()
        } else {
            data["archivedAt"] = FieldValue.delete()
        }

        try await ref.setData(data, merge: true)
    }
}
