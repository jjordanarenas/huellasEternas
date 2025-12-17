//
//  OnboardingViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import Foundation

/// ViewModel que coordina el onboarding.
/// - Controla la pantalla actual
/// - Guarda el estado de completado
/// - Crea el primer memorial usando tu MemorialListViewModel (que ya tienes)
@MainActor
final class OnboardingViewModel: ObservableObject {
    
    enum Step: Int, CaseIterable {
        case welcome
        case features
        case createMemorial
    }
    
    @Published var step: Step = .welcome
    
    // Campos del formulario de "primer memorial"
    @Published var petName: String = ""
    @Published var petType: PetType = .dog
    @Published var shortQuote: String = ""
    
    // Estado UI
    @Published var isCreating: Bool = false
    @Published var errorMessage: String? = nil
    
    private let onboardingState: OnboardingState
    
    init(onboardingState: OnboardingState = OnboardingState()) {
        self.onboardingState = onboardingState
    }
    
    func next() {
        guard let nextStep = Step(rawValue: step.rawValue + 1) else { return }
        step = nextStep
    }
    
    func back() {
        guard let prevStep = Step(rawValue: step.rawValue - 1) else { return }
        step = prevStep
    }
    
    /// Completa onboarding y crea memorial.
    /// - Parameters:
    ///   - memorialListVM: tu VM principal que tiene addMemorial(...)
    ///   - onFinished: callback para cerrar onboarding
    func createFirstMemorial(
        using memorialListVM: MemorialListViewModel,
        onFinished: () -> Void
    ) {
        errorMessage = nil
        
        let name = petName.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            errorMessage = "Pon el nombre de tu mascota para crear el memorial."
            return
        }
        
        isCreating = true
        
        // Creamos memorial con el método que ya tienes.
        // Si tu addMemorial ya hace el guardado async en Firestore, perfecto.
        _ = memorialListVM.addMemorial(
            name: name,
            petType: petType,
            shortQuote: shortQuote
        )

        // Para MVP: lo marcamos como completado al instante.
        // Si quieres, podemos esperar a confirmación real de Firestore.
        onboardingState.markCompleted()
        
        isCreating = false
        onFinished()
    }
}
