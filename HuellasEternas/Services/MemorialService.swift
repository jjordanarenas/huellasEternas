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

            // Campos obligatorios
            guard
                let name = data["name"] as? String,
                let petTypeRaw = data["petType"] as? String,
                let petType = PetType(rawValue: petTypeRaw)
            else {
                return nil
            }

            // ID: intentamos leer el "id" guardado, si no usamos el documentID
            let idString = data["id"] as? String ?? doc.documentID
            guard let uuid = UUID(uuidString: idString) else {
                return nil
            }

            // Fechas opcionales
            let birthDate = (data["birthDate"] as? Timestamp)?.dateValue()
            let deathDate = (data["deathDate"] as? Timestamp)?.dateValue()
            let shortQuote = data["shortQuote"] as? String

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? createdAt

            return Memorial(
                id: uuid,
                name: name,
                petType: petType,
                birthDate: birthDate,
                deathDate: deathDate,
                shortQuote: shortQuote,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }

        return memorials
    }
}
