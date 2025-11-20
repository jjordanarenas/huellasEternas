//
//  JournalViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//


import Foundation

/// ViewModel del Diario emocional.
/// - Expone las entradas para la UI.
/// - Permite añadir y borrar.
/// - Se encarga de guardar/cargar en local.
final class JournalViewModel: ObservableObject {
    
    // Entradas del diario que la vista mostrará
    @Published private(set) var entries: [JournalEntry] = []
    
    // Para mostrar errores básicos si quisieras (ahora mismo solo lo dejamos preparado)
    @Published var errorMessage: String? = nil
    
    // Capa de almacenamiento local
    private let storage: JournalStorage
    
    init(storage: JournalStorage = JournalStorage()) {
        self.storage = storage
        
        // Al crear el ViewModel, cargamos entradas desde local
        loadEntries()
    }
    
    /// Carga las entradas desde el almacenamiento local.
    private func loadEntries() {
        let loaded = storage.load()
        
        // Las ordenamos por fecha (más recientes primero)
        self.entries = loaded.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    /// Añade una entrada nueva al diario y la guarda.
    func addEntry(mood: JournalMood, text: String) {
        // Creamos la entrada
        let newEntry = JournalEntry(mood: mood, text: text)
        
        // La añadimos al principio del array
        entries.insert(newEntry, at: 0)
        
        // Persistimos todo el array
        storage.save(entries: entries)
    }
    
    /// Borra una entrada existente.
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        storage.save(entries: entries)
    }
    
    /// Borra entradas en función de índices (para usar con .onDelete en SwiftUI List, por ejemplo).
    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        storage.save(entries: entries)
    }
}
