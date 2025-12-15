//
//  MemorialService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 19/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Servicio responsable de guardar y leer memoriales en Firestore.
final class MemorialService {

    private let db = Firestore.firestore()

    // MARK: - Guardar (crear/actualizar) memorial

    /// Guarda un memorial en Firestore bajo:
    /// memorials/{memorial.id.uuidString}
    ///
    /// IMPORTANTE:
    /// - Requiere que haya usuario autenticado.
    /// - Fuerza a que ownerUid sea siempre el uid del usuario actual (fuente de verdad).
    func saveMemorial(_ memorial: Memorial) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw MemorialServiceError.notAuthenticated
        }

        let documentId = memorial.id.uuidString

        // Partimos del diccionario del memorial...
        var data = memorial.toDictionary

        // ...pero FORZAMOS ownerUid al uid actual para evitar inconsistencias.
        data["ownerUid"] = uid

        // Opcional pero recomendable: mantener updatedAt consistente en servidor
        data["updatedAt"] = FieldValue.serverTimestamp()

        // Si te interesa, también puedes asegurar createdAt solo en creación
        // (para MVP, merge y serverTimestamp en updatedAt es suficiente).

        try await db
            .collection("memorials")
            .document(documentId)
            .setData(data, merge: true)
    }

    // MARK: - Obtener todos los memoriales

    /// Obtiene todos los memoriales guardados en Firestore.
    /// De momento no filtramos por usuario; más adelante podríamos.
    func fetchAllMemorials() async throws -> [Memorial] {
        let snapshot = try await db
            .collection("memorials")
            .order(by: "createdAt", descending: false)
            .getDocuments()

        // 👇 IMPORTANTE: tipamos el closure como Memorial? para que `return nil` sea válido
        let memorials: [Memorial] = snapshot.documents.compactMap { (doc) -> Memorial? in
            let data = doc.data()

            // Obligatorios
            guard
                let name = data["name"] as? String,
                let petTypeRaw = data["petType"] as? String,
                let petType = PetType(rawValue: petTypeRaw),
                let ownerUid = data["ownerUid"] as? String,
                !ownerUid.isEmpty
            else {
                return nil
            }

            // ID
            let idString = (data["id"] as? String) ?? doc.documentID
            guard let uuid = UUID(uuidString: idString) else { return nil }

            // Opcionales
            let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
            let deathDate = (data["deathDate"] as? Timestamp)?.dateValue()
            let shortQuote = data["shortQuote"] as? String

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? createdAt

            // shareToken (si falta, generamos uno localmente; idealmente lo migras y lo guardas)
            let shareToken: String
            if let token = data["shareToken"] as? String, !token.isEmpty {
                shareToken = token
            } else {
                shareToken = Memorial.generateShareToken()
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
                ownerUid: ownerUid,
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
            let petType = PetType(rawValue: petTypeRaw),
            let ownerUid = data["ownerUid"] as? String,
            !ownerUid.isEmpty
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
            ownerUid: ownerUid,
            shareToken: shareToken
        )
    }

    enum MemorialServiceError: Error {
        case notAuthenticated
    }
}
