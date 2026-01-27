//
//  RoutineProgressStore.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 27/1/26.
//


import Foundation

/// Persistencia local muy simple para publicar rápido.
/// Guarda:
/// - contador de completadas
/// - última fecha de completado
final class RoutineProgressStore {
    private let defaults = UserDefaults.standard
    private let countPrefix = "routine_count_"
    private let lastPrefix = "routine_last_"

    func completionCount(for id: String) -> Int {
        defaults.integer(forKey: countPrefix + id)
    }

    func lastCompletedAt(for id: String) -> Date? {
        defaults.object(forKey: lastPrefix + id) as? Date
    }

    func markCompleted(id: String) {
        let keyCount = countPrefix + id
        let current = defaults.integer(forKey: keyCount)
        defaults.set(current + 1, forKey: keyCount)
        defaults.set(Date(), forKey: lastPrefix + id)
    }
}
