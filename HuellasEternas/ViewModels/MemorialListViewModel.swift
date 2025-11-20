//
//  MemorialListViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation

final class MemorialListViewModel: ObservableObject {

    @Published var memorials: [Memorial] = []

    // Estado de carga y error (para la UI)
    @Published var isLoading: Bool = false
    @Published var loadErrorMessage: String? = nil

    // Servicio para Firestore
    private let memorialService: MemorialService

    init(memorialService: MemorialService = MemorialService()) {
        self.memorialService = memorialService

        // Nada más crearse el ViewModel, cargamos memoriales de Firestore
        Task {
            await loadMemorials()
        }
    }

    // MARK: - Cargar memoriales desde Firestore

    /// Carga todos los memoriales desde Firestore y actualiza la lista.
    @MainActor
    func loadMemorials() async {
        // Evitamos llamar dos veces a la vez
        guard !isLoading else { return }

        isLoading = true
        loadErrorMessage = nil

        do {
            let fetched = try await memorialService.fetchAllMemorials()
            self.memorials = fetched
        } catch {
            print("❌ Error al cargar memoriales: \(error)")
            self.loadErrorMessage = "No se han podido cargar tus memoriales."
        }

        isLoading = false
    }

    // MARK: - Añadir memorial (sigue funcionando igual que antes)

    func addMemorial(name: String, petType: PetType) {
        let newMemorial = Memorial.createNew(name: name, petType: petType)

        // 1. Lo añadimos a la lista local para que la UI se actualice
        memorials.append(newMemorial)

        // 2. Lo guardamos en Firestore
        Task {
            do {
                try await memorialService.saveMemorial(newMemorial)
                print("✅ Memorial guardado en Firestore con id \(newMemorial.id.uuidString)")
            } catch {
                print("❌ Error al guardar memorial en Firestore: \(error)")
                // Aquí podrías gestionar un estado de error si quieres
            }
        }
    }
}
