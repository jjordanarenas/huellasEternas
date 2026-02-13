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

            Text("¿Qué puedes hacer aquí?")
                .font(.title)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            VStack(alignment: .leading, spacing: 12) {
                OnboardingFeatureRow(text: "Crear memoriales con fotos y frases", systemImage: "photo.on.rectangle.angled")
                OnboardingFeatureRow(text: "Encender velas con dedicatorias", systemImage: "candle.fill")
                OnboardingFeatureRow(text: "Diario emocional para desahogarte", systemImage: "book.closed.fill")
                OnboardingFeatureRow(text: "Mensajes de ánimo con IA cuando lo necesites", systemImage: "sparkles")
                OnboardingFeatureRow(text: "Compartir el memorial con amigos/familia", systemImage: "square.and.arrow.up")
            }
            .padding()
            .background(HuellasColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(HuellasColor.divider, lineWidth: 1)
            )

            Text("Empecemos creando el primer memorial.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
                .padding(.top, 6)

            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OnboardingFeatureRow: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(HuellasColor.primaryDark)
            Text(text)
                .foregroundStyle(HuellasColor.textPrimary)
            Spacer()
        }
        .font(.body)
    }
}
