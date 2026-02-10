//
//  OnboardingFeaturesStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

struct OnboardingFeaturesStepView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            Spacer()

            header

            featuresGrid

            footerText

            Spacer()
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("¿Qué puedes hacer aquí?")
                .font(.title)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Un espacio cálido para recordar, acompañarte y compartir ese cariño con quien lo necesite.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
    }

    private var featuresGrid: some View {
        VStack(spacing: 12) {
            FeatureCard(
                title: "Crear memoriales",
                subtitle: "Con fotos, frases y detalles importantes.",
                systemImage: "photo.on.rectangle.angled"
            )

            FeatureCard(
                title: "Encender velas",
                subtitle: "Con dedicatorias para honrar su recuerdo.",
                systemImage: "candle.fill"
            )

            FeatureCard(
                title: "Diario emocional",
                subtitle: "Para escribir y soltar lo que llevas dentro.",
                systemImage: "book.closed.fill"
            )

            FeatureCard(
                title: "Mensajes de ánimo con IA",
                subtitle: "Cuando te falten fuerzas o palabras.",
                systemImage: "sparkles"
            )

            FeatureCard(
                title: "Compartir con familia",
                subtitle: "Para que otros también puedan acompañarte.",
                systemImage: "square.and.arrow.up"
            )
        }
        .padding(.top, 4)
    }

    private var footerText: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .foregroundStyle(HuellasColor.primaryDark)

            Text("Empecemos creando el primer memorial.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)

            Spacer()
        }
        .padding(.top, 8)
    }
}

private struct FeatureCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundStyle(HuellasColor.primaryDark)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(HuellasColor.textPrimary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)
            }

            Spacer()
        }
        .padding(14)
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }
}
