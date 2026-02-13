//
//  OnboardingBottomBar.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

struct OnboardingBottomBar: View {

    let step: OnboardingViewModel.Step
    let onBack: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {

            if step != .welcome {
                Button("Atrás") { onBack() }
                    .buttonStyle(.bordered)
                    .tint(HuellasColor.primaryDark)
            }

            Spacer()

            if step != .createMemorial {
                Button("Continuar") { onNext() }
                    .buttonStyle(.borderedProminent)
                    .tint(HuellasColor.primary)
            }
        }
        //.tint(HuellasColor.primaryDark)
       // .preferredColorScheme(.light)
    }
}
