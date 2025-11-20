//
//  JournalMood.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import Foundation

/// Estado de ánimo para una entrada del diario.
/// Lo hacemos Codable para poder guardarlo fácilmente.
enum JournalMood: String, CaseIterable, Identifiable, Codable {
    case verySad = "Muy triste"
    case sad = "Triste"
    case reflective = "Reflexivo"
    case peaceful = "En paz"
    case grateful = "Agradecido"
    
    var id: String { rawValue }
    
    /// Emoji asociado a cada estado de ánimo.
    var emoji: String {
        switch self {
        case .verySad:   return "😭"
        case .sad:       return "😢"
        case .reflective:return "🤍"
        case .peaceful:  return "🕊"
        case .grateful:  return "🙏"
        }
    }
}
