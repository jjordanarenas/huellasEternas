//
//  OnboardingState.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import Foundation

/// Guarda si el onboarding ya se ha completado.
/// Para MVP usamos UserDefaults.
/// Más adelante podrías moverlo a Firestore o a tu colección users/{uid}.
final class OnboardingState {
    
    private let key = "onboarding_completed_v1"
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    var isCompleted: Bool {
        defaults.bool(forKey: key)
    }
    
    func markCompleted() {
        defaults.set(true, forKey: key)
    }
    
    func resetForTesting() {
        defaults.set(false, forKey: key)
    }
}
