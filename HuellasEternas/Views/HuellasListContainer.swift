//
//  HuellasListContainer.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 29/1/26.
//

import SwiftUI

/// Contenedor base para pantallas con List o Form.
/// Evita el fondo blanco por defecto y mantiene la paleta en iOS.
struct HuellasListContainer<Content: View>: View {
    let topInset: CGFloat
    @ViewBuilder let content: Content

    init(topInset: CGFloat = 10, @ViewBuilder content: () -> Content) {
        self.topInset = topInset
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if topInset > 0 {
                Color.clear
                    .frame(height: topInset)
                    .accessibilityHidden(true)
            }
            content
        }
        .background(HuellasColor.background)
    }
}
