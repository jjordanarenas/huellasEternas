//
//  JournalEntry.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import Foundation

/// Entrada del diario emocional.
/// De momento no lo guardamos en Firestore, solo en local.
/// Más adelante podremos añadir `memorialId` si quieres ligarlo a una mascota concreta.
struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    
    var mood: JournalMood
    var text: String
    
    init(id: UUID = UUID(),
         createdAt: Date = Date(),
         mood: JournalMood,
         text: String) {
        self.id = id
        self.createdAt = createdAt
        self.mood = mood
        self.text = text
    }
}
