//
//  JournalStorage.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//


import Foundation

/// Encargado de guardar y cargar las entradas del diario en local.
/// Usamos UserDefaults + JSON como solución simple.
/// Más adelante podrías cambiarlo a SwiftData/CoreData sin tocar mucho el ViewModel.
final class JournalStorage {
    
    // Clave donde guardaremos el JSON en UserDefaults
    private let storageKey = "journal_entries_v1"
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    /// Guarda el array completo de entradas en UserDefaults.
    func save(entries: [JournalEntry]) {
        do {
            let data = try JSONEncoder().encode(entries)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("❌ Error al codificar JournalEntry: \(error)")
        }
    }
    
    /// Carga el array completo de entradas desde UserDefaults.
    func load() -> [JournalEntry] {
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let entries = try JSONDecoder().decode([JournalEntry].self, from: data)
            return entries
        } catch {
            print("❌ Error al decodificar JournalEntry: \(error)")
            return []
        }
    }
}
