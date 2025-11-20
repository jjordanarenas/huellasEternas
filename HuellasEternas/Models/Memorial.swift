//
//  Memorial.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation

// Modelo principal de un memorial.
// Conforma a Identifiable para poder usarlo en ForEach/List.
// También Hashable por si lo necesitamos en NavigationStack.
struct Memorial: Identifiable, Hashable, Codable {
    let id: UUID          // identificador único
    
    var name: String      // nombre de la mascota
    var petType: PetType  // tipo de mascota
    
    var birthDate: Date?  // fecha de nacimiento (opcional)
    var deathDate: Date?  // fecha de fallecimiento (opcional)
    
    var shortQuote: String? // frase corta tipo "Gracias por todo lo que me diste"

    var createdAt: Date
    var updatedAt: Date
    // Más adelante aquí añadiremos URL de foto principal, etc.
    
    init(id: UUID,
         name: String,
         petType: PetType,
         birthDate: Date? = nil,
         deathDate: Date? = nil,
         shortQuote: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {

        self.id = id
        self.name = name
        self.petType = petType
        self.birthDate = birthDate
        self.deathDate = deathDate
        self.shortQuote = shortQuote
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Fábrica para crear un memorial NUEVO con UUID nuevo.
    // Úsala solo cuando estés creando memoriales nuevos.
    static func createNew(name: String,
                             petType: PetType,
                             birthDate: Date? = nil,
                             deathDate: Date? = nil,
                             shortQuote: String? = nil) -> Memorial {
       let now = Date()
       return Memorial(
           id: UUID(),
           name: name,
           petType: petType,
           birthDate: birthDate,
           deathDate: deathDate,
           shortQuote: shortQuote,
           createdAt: now,
           updatedAt: now
       )
    }

    /// Diccionario para enviar a Firestore.
    /// Firestore convierte automáticamente Date → Timestamp.
    var toDictionary: [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "petType": petType.rawValue,
            "birthDate": birthDate as Any,
            "deathDate": deathDate as Any,
            "shortQuote": shortQuote as Any,
            "createdAt": createdAt,
            "updatedAt": updatedAt
        ]
    }
}
