//
//  HuellasColor.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 29/1/26.
//

import SwiftUI

enum HuellasColor {
    // Fondos
    static let background = Color(hex: "#F6EAD1")           // crema principal
    static let backgroundSecondary = Color(hex: "#FBF8F2")  // marfil

    // Acentos (vela)
    static let primary = Color(hex: "#E6B96A")              // dorado suave
    static let primaryDark = Color(hex: "#C99A4A")          // ámbar

    // Textos
    static let textPrimary = Color(hex: "#5C452A")          // marrón oscuro
    static let textSecondary = Color(hex: "#8A7355")        // marrón claro

    // Separadores/bordes
    static let divider = Color(hex: "#D8CDBA")              // beige grisáceo

    // “Card” fondo (para secciones)
    static let card = Color(hex: "#FBF8F2")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
