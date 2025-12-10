//
//  AIUsageManager.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 4/12/25.
//


import Foundation

/// Gestiona el uso de mensajes de IA gratuitos por mes para usuarios no Premium.
/// - Guarda el número de mensajes usados en UserDefaults.
/// - Resetea automáticamente al cambiar de mes.
final class AIUsageManager {
    
    /// Límite de mensajes gratis al mes para usuarios no Premium.
    /// Puedes cambiar este valor (por ejemplo 3 o 5).
    private let freeMessagesPerMonth = 3
    
    /// Claves para UserDefaults
    private let usageKey = "ai_free_messages_used"
    private let monthKey = "ai_free_messages_month"
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        resetIfNewMonth()
    }
    
    /// Comprueba si el usuario puede usar otro mensaje gratis este mes.
    func canUseFreeMessage() -> Bool {
        resetIfNewMonth()
        let used = defaults.integer(forKey: usageKey)
        return used < freeMessagesPerMonth
    }
    
    /// Registra que el usuario ha usado un mensaje gratis.
    func registerMessageUsage() {
        resetIfNewMonth()
        let used = defaults.integer(forKey: usageKey)
        defaults.set(used + 1, forKey: usageKey)
    }
    
    /// Devuelve cuántos mensajes gratis le quedan este mes.
    func remainingFreeMessages() -> Int {
        resetIfNewMonth()
        let used = defaults.integer(forKey: usageKey)
        let remaining = freeMessagesPerMonth - used
        return max(0, remaining)
    }
    
    /// Devuelve el límite total de mensajes gratis al mes.
    func freeLimitPerMonth() -> Int {
        return freeMessagesPerMonth
    }
    
    /// Si hemos cambiado de mes, resetea el contador.
    private func resetIfNewMonth() {
        let currentMonth = currentMonthIdentifier()
        let storedMonth = defaults.string(forKey: monthKey)
        
        if storedMonth != currentMonth {
            // Nuevo mes → reseteamos contador y actualizamos mes
            defaults.set(currentMonth, forKey: monthKey)
            defaults.set(0, forKey: usageKey)
        }
    }
    
    /// Identificador de mes tipo "2025-12"
    private func currentMonthIdentifier() -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        let year = comps.year ?? 0
        let month = comps.month ?? 0
        return String(format: "%04d-%02d", year, month)
    }
}
