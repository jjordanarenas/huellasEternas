//
//  MemorialService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 19/11/25.
//

import Foundation
import FirebaseFirestore

/// Servicio responsable de guardar y leer memoriales en Firestore.
final class MemorialService {

    private let db = Firestore.firestore()

    // MARK: - Guardar (crear/actualizar) memorial

    /// Guarda un memorial en Firestore bajo el documento:
    /// memorials/{memorial.id.uuidString}
    func saveMemorial(_ memorial: Memorial) async throws {
        let documentId = memorial.id.uuidString

        try await db
            .collection("memorials")
            .document(documentId)
            .setData(memorial.toDictionary, merge: true)
    }

    // MARK: - Obtener todos los memoriales

    /// Obtiene todos los memoriales guardados en Firestore.
    /// De momento no filtramos por usuario; más adelante podríamos.
    func fetchAllMemorials() async throws -> [Memorial] {
        let snapshot = try await db
            .collection("memorials")
            .order(by: "createdAt", descending: false)
            .getDocuments()

        let memorials: [Memorial] = snapshot.documents.compactMap { doc in
            let data = doc.data()

            guard
                let name = data["name"] as? String,
                let petTypeRaw = data["petType"] as? String,
                let petType = PetType(rawValue: petTypeRaw)
            else {
                return nil
            }

            let idString = data["id"] as? String ?? doc.documentID
            guard let uuid = UUID(uuidString: idString) else {
                return nil
            }

            let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
            let deathDate = (data["deathDate"] as? Timestamp)?.dateValue()
            let shortQuote = data["shortQuote"] as? String

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? createdAt

            // 👇 Intentamos leer shareToken. Si no existe (memorial antiguo),
            // generamos uno nuevo para ese memorial.
            let shareToken: String
            if let existingToken = data["shareToken"] as? String, !existingToken.isEmpty {
                shareToken = existingToken
            } else {
                shareToken = Memorial.generateShareToken()
                // Opcional: podríamos re-guardar el memorial con este nuevo token.
                // Lo dejamos pendiente para no complicarlo ahora.
            }

            return Memorial(
                id: uuid,
                name: name,
                petType: petType,
                birthDate: birthDate,
                deathDate: deathDate,
                shortQuote: shortQuote,
                createdAt: createdAt,
                updatedAt: updatedAt,
                shareToken: shareToken
            )
        }

        return memorials
    }

    /// Busca un memorial en Firestore por su shareToken.
    /// Devuelve nil si no hay ninguno con ese token.
    func fetchMemorial(byShareToken token: String) async throws -> Memorial? {
        let snapshot = try await db
            .collection("memorials")
            .whereField("shareToken", isEqualTo: token)
            .limit(to: 1)
            .getDocuments()

        guard let doc = snapshot.documents.first else {
            return nil
        }

        let data = doc.data()

        guard
            let name = data["name"] as? String,
            let petTypeRaw = data["petType"] as? String,
            let petType = PetType(rawValue: petTypeRaw)
        else {
            return nil
        }

        let idString = data["id"] as? String ?? doc.documentID
        guard let uuid = UUID(uuidString: idString) else {
            return nil
        }

        let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
        let deathDate = (data["deathDate"] as? Timestamp)?.dateValue()
        let shortQuote = data["shortQuote"] as? String

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? createdAt

        let shareToken = (data["shareToken"] as? String) ?? token

        return Memorial(
            id: uuid,
            name: name,
            petType: petType,
            birthDate: birthDate,
            deathDate: deathDate,
            shortQuote: shortQuote,
            createdAt: createdAt,
            updatedAt: updatedAt,
            shareToken: shareToken
        )
    }
}
