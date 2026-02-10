//
//  OnboardingWelcomeStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

struct OnboardingWelcomeStepView: View {

    var body: some View {
        VStack(spacing: 28) {

            Spacer()

            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(HuellasColor.primaryDark)

            VStack(spacing: 12) {
                Text("Un lugar para recordar")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(HuellasColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("""
                Crea un memorial para tu mascota, recibe apoyo cuando lo necesites \
                y permite que amigos y familia también puedan rendir homenaje.
                """)
                .font(.body)
                .foregroundStyle(HuellasColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
            }

            Spacer()
        }
        .padding()
    }
}
