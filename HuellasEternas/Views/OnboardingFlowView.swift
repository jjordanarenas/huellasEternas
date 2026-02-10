//
//  OnboardingFlowView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

/// Contenedor del onboarding.
/// Decide qué pantalla mostrar según el step del ViewModel.
struct OnboardingFlowView: View {

    @EnvironmentObject var memorialListVM: MemorialListViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        NavigationStack {
            HuellasScreen {
                VStack(spacing: 100) {

                    // CONTENIDO PRINCIPAL
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .animation(.easeInOut(duration: 0.22), value: vm.step)

                    // BARRA INFERIOR (sin dobles padding/background)
                    OnboardingBottomBar(
                        step: vm.step,
                        onBack: { vm.back() },
                        onNext: { vm.next() }
                    )
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch vm.step {
        case .welcome:
            OnboardingWelcomeStepView()
                .padding() // ✅ este step sí lo necesita

        case .features:
            OnboardingFeaturesStepView()
                .padding() // ✅ este step sí lo necesita

        case .createMemorial:
            // ✅ este step NO debe llevar padding externo porque ya es un Form en contenedor
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

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                dismiss()
            } label: {
                Text("Saltar")
                    .foregroundStyle(HuellasColor.primaryDark)
            }
            // ✅ Mejor que opacity: evita que sea “clicable” cuando no toca
            .disabled(vm.step == .createMemorial)
            .opacity(vm.step == .createMemorial ? 0 : 1)
        }
    }
}
