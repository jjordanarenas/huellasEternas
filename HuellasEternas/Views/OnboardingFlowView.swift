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
            VStack {
                // Cambiamos contenido según step
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Barra inferior con navegación (Back/Next)
                OnboardingBottomBar(
                    step: vm.step,
                    onBack: { vm.back() },
                    onNext: { vm.next() }
                )
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón de cerrar (solo si quieres permitir saltar onboarding)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Saltar") {
                        // En MVP yo permitiría saltar, pero
                        // (1) no marcar completed
                        // (2) usuario puede crear memorial luego
                        dismiss()
                    }
                    .opacity(vm.step == .createMemorial ? 0 : 1) // opcional
                }
            }
        }
    }
}
