//
//  Routine.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 27/1/26.
//


import Foundation

/// Modelo simple de rutina (MVP).
/// - No depende de Firestore.
/// - Persistimos progreso localmente con UserDefaults.
struct Routine: Identifiable, Codable, Hashable {
    let id: String                 // String para ids estables
    let title: String
    let subtitle: String
    let iconSystemName: String
    let steps: [String]
    let estimatedMinutes: Int
}

/// Fuente de rutinas "hardcodeadas" para publicar rápido.
/// Más adelante puedes mover esto a Firestore o Remote Config.
enum RoutineCatalog {
    static let all: [Routine] = [
        Routine(
            id: "breath_2min",
            title: "Respirar 2 minutos",
            subtitle: "Baja la intensidad del momento, sin pelearte con él.",
            iconSystemName: "lungs.fill",
            steps: [
                "Inhala 4 segundos",
                "Sostén 2 segundos",
                "Exhala 6 segundos",
                "Repite 6 veces"
            ],
            estimatedMinutes: 2
        ),
        Routine(
            id: "write_3lines",
            title: "Escribir 3 líneas",
            subtitle: "Suelta lo que tengas dentro, sin juzgarte.",
            iconSystemName: "pencil.and.outline",
            steps: [
                "¿Qué siento ahora mismo?",
                "¿Qué echo de menos hoy?",
                "¿Qué necesito para estar un 1% mejor?"
            ],
            estimatedMinutes: 3
        ),
        Routine(
            id: "memory_smile",
            title: "Un recuerdo bonito",
            subtitle: "Trae un momento bueno a tu presente.",
            iconSystemName: "sparkles",
            steps: [
                "Piensa en un momento concreto con tu mascota",
                "¿Dónde estabais? ¿Qué pasó?",
                "Escribe 1 frase para recordarlo"
            ],
            estimatedMinutes: 3
        ),
        Routine(
            id: "gratitude_1min",
            title: "Gracias por… (1 minuto)",
            subtitle: "Una mini carta de gratitud.",
            iconSystemName: "heart.text.square.fill",
            steps: [
                "Completa: “Gracias por acompañarme cuando…”",
                "Completa: “Gracias por hacerme reír cuando…”",
                "Completa: “Hoy te honro haciendo…”"
            ],
            estimatedMinutes: 1
        ),
        Routine(
            id: "walk_5min",
            title: "Caminar 5 minutos",
            subtitle: "Un reset físico suave.",
            iconSystemName: "figure.walk",
            steps: [
                "Sal 5 minutos (o camina por casa)",
                "Respira normal, sin exigencia",
                "Al volver: bebe agua"
            ],
            estimatedMinutes: 5
        ),
        Routine(
            id: "talk_to_friend",
            title: "Enviar un mensaje a alguien",
            subtitle: "No tienes que llevarlo solo/a.",
            iconSystemName: "message.fill",
            steps: [
                "Elige una persona de confianza",
                "Escribe: “Hoy me he acordado mucho de (nombre). ¿Te puedo contar algo?”",
                "Envíalo sin esperar nada perfecto"
            ],
            estimatedMinutes: 2
        )
    ]
}
