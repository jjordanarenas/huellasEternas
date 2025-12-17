//
//  OnboardingFeaturesStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import SwiftUI

struct OnboardingFeaturesStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            
            Text("¿Qué puedes hacer aquí?")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Crear memoriales con fotos y frases", systemImage: "photo.on.rectangle.angled")
                Label("Encender velas con dedicatorias", systemImage: "candle.fill")
                Label("Diario emocional para desahogarte", systemImage: "book.closed.fill")
                Label("Mensajes de ánimo con IA cuando lo necesites", systemImage: "sparkles")
                Label("Compartir el memorial con amigos/familia", systemImage: "square.and.arrow.up")
            }
            .font(.body)
            
            Text("Empecemos creando el primer memorial.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }
}
