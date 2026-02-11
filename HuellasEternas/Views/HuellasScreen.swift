//
//  HuellasScreen.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/2/26.
//


import SwiftUI

/// Contenedor base para pantallas "normales" (ScrollView, VStack…).
/// Aplica fondo global + tint de la app + color scheme.
struct HuellasScreen<Content: View>: View {

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            HuellasColor.background
                .ignoresSafeArea()   // ✅ CLAVE: cubre también bajo TabBar/NavBar

            content
        }
        .tint(HuellasColor.primaryDark)
        .preferredColorScheme(.light)
    }
}
