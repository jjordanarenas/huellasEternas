//
//  OnboardingFlowView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

struct OnboardingFlowView: View {

    @EnvironmentObject var memorialListVM: MemorialListViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = OnboardingViewModel()

    let onSkip: () -> Void   // ✅

    var body: some View {
        NavigationStack {
            ZStack {
                HuellasColor.background.ignoresSafeArea()

                // ✅ Contenido principal scrollable (no se corta en ningún iPhone)
                ScrollView {
                    Group {
                        switch vm.step {
                        case .welcome:
                            OnboardingWelcomeStepView()

                        case .features:
                            OnboardingFeaturesStepView()

                        case .createMemorial:
                            OnboardingCreateMemorialStepView(
                                petName: $vm.petName,
                                petType: $vm.petType,
                                shortQuote: $vm.shortQuote,
                                errorMessage: vm.errorMessage,
                                isCreating: vm.isCreating,
                                onCreate: {
                                    vm.createFirstMemorial(using: memorialListVM) {
                                        dismiss()
                                    }
                                }
                            )
                        }
                    }
                    .padding(20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                   /* .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .padding(.top, 8)
                    .padding(.bottom, 24) // aire antes de la bottom bar*/
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(HuellasColor.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Saltar") { dismiss() }
                        .foregroundStyle(HuellasColor.textSecondary)
                }
            }

            // ✅ Bottom bar fija, siempre visible, sin blancos alrededor
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider().background(HuellasColor.divider)

                    OnboardingBottomBar(
                        step: vm.step,
                        onBack: { vm.back() },
                        onNext: { vm.next() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                }
            }
        }
        .tint(HuellasColor.primaryDark)
        .preferredColorScheme(.light)
    }
}
