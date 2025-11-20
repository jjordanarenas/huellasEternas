//
//  Candle.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation

// Modelo de vela que vamos a guardar en Firestore
struct Candle: Identifiable, Codable {
    // id del documento en Firestore
    var id: String = UUID().uuidString
    
    // id del memorial (usaremos memorial.id.uuidString)
    var memorialId: String
    
    // Nombre opcional de la persona que enciende la vela
    var fromName: String?
    
    // Mensaje opcional junto a la vela
    var message: String?
    
    // Fecha en la que se encendió la vela
    var createdAt: Date = Date()
    
    // Constructor cómodo
    init(id: String = UUID().uuidString,
         memorialId: String,
         fromName: String? = nil,
         message: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.memorialId = memorialId
        self.fromName = fromName
        self.message = message
        self.createdAt = createdAt
    }
    
    // Diccionario para enviar a Firestore (porque Firestore usa [String: Any])
    var toDictionary: [String: Any] {
        [
            "memorialId": memorialId,
            "fromName": fromName as Any,
            "message": message as Any,
            "createdAt": createdAt
        ]
    }
}
