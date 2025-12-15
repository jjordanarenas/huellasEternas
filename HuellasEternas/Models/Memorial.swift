//
//  Memorial.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation

struct Memorial: Identifiable, Hashable, Codable {
    let id: UUID

    var name: String
    var petType: PetType
    var birthDate: Date?
    var deathDate: Date?
    var shortQuote: String?

    var createdAt: Date
    var updatedAt: Date

    /// Usuario dueño del memorial (uid de Firebase Auth)
    var ownerUid: String

    /// Código que usaremos para compartir este memorial con amigos/familia.
    /// Puede ser un string corto, legible, que incluimos también en un link.
    var shareToken: String

    init(id: UUID,
         name: String,
         petType: PetType,
         birthDate: Date? = nil,
         deathDate: Date? = nil,
         shortQuote: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         ownerUid: String,
         shareToken: String) {

        self.id = id
        self.name = name
        self.petType = petType
        self.birthDate = birthDate
        self.deathDate = deathDate
        self.shortQuote = shortQuote
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.ownerUid = ownerUid
        self.shareToken = shareToken
    }

    /// Fábrica para crear un memorial NUEVO.
    static func createNew(name: String,
                          petType: PetType,
                          birthDate: Date? = nil,
                          deathDate: Date? = nil,
                          shortQuote: String? = nil,
                          ownerUid: String) -> Memorial {
        let now = Date()
        return Memorial(
            id: UUID(),
            name: name,
            petType: petType,
            birthDate: birthDate,
            deathDate: deathDate,
            shortQuote: shortQuote,
            createdAt: now,
            updatedAt: now,
            ownerUid: ownerUid,
            shareToken: Self.generateShareToken()
        )
    }

    /// Genera un token de invitación/compartir relativamente corto.
    /// (Aquí puedes afinar el formato que más te guste).
    static func generateShareToken() -> String {
        // Ejemplo sencillo: 8 caracteres alfanuméricos en mayúsculas
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<8).compactMap { _ in chars.randomElement() })
    }

    /// Diccionario para enviar a Firestore.
    var toDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "petType": petType.rawValue,
            "birthDate": birthDate as Any,
            "deathDate": deathDate as Any,
            "shortQuote": shortQuote as Any,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "ownerUid": ownerUid,
            "shareToken": shareToken
        ]
    }
}
