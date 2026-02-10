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
                Button {
                    onBack()
                } label: {
                    Text("Atrás")
                        .frame(minWidth: 90)
                }
                .buttonStyle(.bordered)
                .tint(HuellasColor.primaryDark)
            }

            Spacer()

            if step != .createMemorial {
                Button {
                    //onNext()
                    withAnimation(.easeInOut(duration: 0.22)) {
                        onNext()
                    }
                } label: {
                    Text("Continuar")
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .tint(HuellasColor.primary)
            }
        }
        .padding()
        .background(HuellasColor.background)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(HuellasColor.divider),
            alignment: .top
        )
    }
}
