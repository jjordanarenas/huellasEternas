//
//  CandleService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//


import Foundation
import FirebaseFirestore

// Servicio responsable de guardar y leer velas en Firestore
final class CandleService {
    
    // Referencia a la base de datos de Firestore
    private let db = Firestore.firestore()
    
    // MARK: - Añadir una vela
    
    /// Añade una vela a Firestore para el memorial dado.
    /// - Parameters:
    ///   - memorialId: id del memorial (usaremos memorial.id.uuidString)
    ///   - fromName: nombre opcional de la persona que enciende la vela
    ///   - message: mensaje opcional
    func addCandle(
        memorialId: String,
        fromName: String? = nil,
        message: String? = nil
    ) async throws {
        
        // Creamos el modelo local de vela
        let candle = Candle(
            memorialId: memorialId,
            fromName: fromName,
            message: message
        )
        
        // Ruta: memorials/{memorialId}/candles/{autoId}
        let candlesCollection = db
            .collection("memorials")
            .document(memorialId)
            .collection("candles")
        
        // Usamos async/await para no anidar closures
        try await candlesCollection.addDocument(data: candle.toDictionary)
    }
    
    // MARK: - Ejemplo de obtener el número de velas (por si lo necesitas después)
    
    /// Devuelve el número de velas para un memorial.
    func getCandleCount(for memorialId: String) async throws -> Int {
        let snapshot = try await db
            .collection("memorials")
            .document(memorialId)
            .collection("candles")
            .getDocuments()
        
        return snapshot.documents.count
    }

    // MARK: - Obtener todas las velas de un memorial

    /// Lee todas las velas de un memorial desde Firestore,
    /// ordenadas por fecha de creación (más reciente primero).
    func fetchCandles(for memorialId: String) async throws -> [Candle] {
        // Hacemos una query a la subcolección "candles" del memorial
        let snapshot = try await db
            .collection("memorials")
            .document(memorialId)
            .collection("candles")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        // Convertimos cada documento en un Candle
        let candles: [Candle] = snapshot.documents.compactMap { doc in
            let data = doc.data()

            // Intentamos leer cada campo con el tipo apropiado
            let memorialId = data["memorialId"] as? String ?? memorialId
            let fromName = data["fromName"] as? String
            let message = data["message"] as? String

            // Firestore guarda fechas como Timestamp → las convertimos a Date
            let createdAt: Date
            if let timestamp = data["createdAt"] as? Timestamp {
                createdAt = timestamp.dateValue()
            } else {
                createdAt = Date() // valor por defecto si faltase el campo
            }

            return Candle(
                id: doc.documentID,
                memorialId: memorialId,
                fromName: fromName,
                message: message,
                createdAt: createdAt
            )
        }

        return candles
    }
}
