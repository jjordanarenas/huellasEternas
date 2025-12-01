//
//  ComfortMessageService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import Foundation

final class ComfortMessageService {

    /// URL de tu Cloud Function.
    /// Sustituye por la URL real que te da Firebase al desplegar.
    private let endpointURL = URL(string: "https://us-central1-huellaseternasopenai.cloudfunctions.net/generateComfortMessage")!

    /// Genera un mensaje de ánimo breve llamando a tu backend (Cloud Function).
    func generateComfortMessage(
        mood: JournalMood,
        currentText: String
    ) async throws -> String {

        // Construimos el body JSON
        struct RequestBody: Encodable {
            let mood: String
            let currentText: String
        }

        let body = RequestBody(
            mood: moodIdentifier(for: mood),
            currentText: currentText
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(body)

        // Montamos la URLRequest
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        // Llamada HTTP usando async/await
        let (responseData, response) = try await URLSession.shared.data(for: request)

        // Comprobamos status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ComfortMessageError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Intentamos parsear mensaje de error del servidor
            if let serverError = try? JSONDecoder().decode(ServerError.self, from: responseData) {
                throw ComfortMessageError.server(message: serverError.error ?? "Error del servidor (\(httpResponse.statusCode))")
            } else {
                throw ComfortMessageError.server(message: "Error del servidor (\(httpResponse.statusCode))")
            }
        }

        // Parseamos la respuesta correcta
        let decoded = try JSONDecoder().decode(ComfortMessageResponse.self, from: responseData)

        guard let message = decoded.message, !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ComfortMessageError.emptyMessage
        }

        return message
    }

    /// Mapea tu enum de estado de ánimo a un string que enviamos al backend.
    /// Aquí puedes usar "verySad", "sad", etc. tal cual, o algo más humano.
    private func moodIdentifier(for mood: JournalMood) -> String {
        switch mood {
        case .verySad:   return "verySad"
        case .sad:       return "sad"
        case .reflective:return "reflective"
        case .peaceful:  return "peaceful"
        case .grateful:  return "grateful"
        }
    }

    // MARK: - Modelos de respuesta y errores

    /// Estructura de la respuesta JSON esperada desde la función.
    /// {
    ///   "message": "texto de consuelo..."
    /// }
    private struct ComfortMessageResponse: Decodable {
        let message: String?
    }

    /// Posible error JSON devuelto por el backend.
    /// {
    ///   "error": "mensaje de error"
    /// }
    private struct ServerError: Decodable {
        let error: String?
    }

    enum ComfortMessageError: Error, LocalizedError {
        case invalidResponse
        case server(message: String)
        case emptyMessage

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Respuesta no válida del servidor."
            case .server(let message):
                return message
            case .emptyMessage:
                return "No se ha generado ningún mensaje de ánimo."
            }
        }
    }
}
