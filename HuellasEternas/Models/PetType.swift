//
//  PetType.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation

// Tipo de mascota. Lo hacemos CaseIterable para poder mostrar una lista (Picker).
enum PetType: String, CaseIterable, Identifiable, Codable {
    case dog = "Perro"
    case cat = "Gato"
    case bird = "Pájaro"
    case rabbit = "Conejo"
    case other = "Otra"
    
    // Para usar en ForEach en SwiftUI
    var id: String { rawValue }
}

extension PetType {
    var systemImage: String {
        switch self {
        case .dog: return "pawprint.fill"
        case .cat: return "pawprint"
        case .bird: return "bird.fill"
        case .rabbit: return "hare.fill"
        case .other: return "heart.fill"
        }
    }
}
