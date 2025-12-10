//
//  CandleUsageManager.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 10/12/25.
//


import Foundation

/// Gestiona el uso de velas gratuitas por día para usuarios no Premium.
/// - Guarda el número de velas encendidas hoy en UserDefaults.
/// - Resetea automáticamente al cambiar de día.
final class CandleUsageManager {
    
    /// Límite de velas gratis al día para usuarios no Premium.
    /// Puedes ajustar el valor (por ejemplo 2, 3, etc.)
    private let freeCandlesPerDay = 2
    
    /// Claves para UserDefaults
    private let usageKey = "candle_free_used_today"
    private let dayKey   = "candle_free_day"
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        resetIfNewDay()
    }
    
    /// Comprueba si el usuario puede encender otra vela gratis hoy.
    func canUseFreeCandle() -> Bool {
        resetIfNewDay()
        let used = defaults.integer(forKey: usageKey)
        return used < freeCandlesPerDay
    }
    
    /// Registra que el usuario ha encendido una vela gratis hoy.
    func registerCandleUsage() {
        resetIfNewDay()
        let used = defaults.integer(forKey: usageKey)
        defaults.set(used + 1, forKey: usageKey)
    }
    
    /// Devuelve cuántas velas gratis le quedan hoy.
    func remainingFreeCandlesToday() -> Int {
        resetIfNewDay()
        let used = defaults.integer(forKey: usageKey)
        let remaining = freeCandlesPerDay - used
        return max(0, remaining)
    }
    
    /// Devuelve el límite total de velas gratis al día.
    func freeLimitPerDay() -> Int {
        return freeCandlesPerDay
    }
    
    /// Si hemos cambiado de día, resetea el contador.
    private func resetIfNewDay() {
        let currentDay = currentDayIdentifier()
        let storedDay = defaults.string(forKey: dayKey)
        
        if storedDay != currentDay {
            // Nuevo día → reseteamos contador y actualizamos día
            defaults.set(currentDay, forKey: dayKey)
            defaults.set(0, forKey: usageKey)
        }
    }
    
    /// Identificador de día tipo "2025-12-10"
    private func currentDayIdentifier() -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        let day = comps.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}
