//
//  OnboardingWelcomeStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

struct OnboardingWelcomeStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(HuellasColor.primaryDark)

            Text("Un lugar para recordar")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Crea un memorial para tu mascota, recibe apoyo cuando lo necesites y deja que amigos y familia también puedan rendir homenaje.")
                .font(.body)
                .foregroundStyle(HuellasColor.textSecondary)

            // ✅ evita “vacío raro”, pero deja aire
            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
