//
//  MemorialOrderService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 17/12/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

final class MemorialOrderService {

    private let db = Firestore.firestore()

    enum Relationship: String {
        case owned
        case joined
    }

    /// Devuelve el orden del usuario: [(memorialId, relationship)]
    func fetchOrder() async throws -> [(String, Relationship)] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let snap = try await db
            .collection("users")
            .document(uid)
            .collection("memorialOrder")
            .order(by: "sortIndex", descending: false)
            .getDocuments()

        return snap.documents.compactMap { doc in
            let data = doc.data()
            guard let relRaw = data["relationship"] as? String,
                  let rel = Relationship(rawValue: relRaw) else { return nil }
            return (doc.documentID, rel) // docID = memorialId
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
}
