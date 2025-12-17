//
//  MemorialListViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation
import FirebaseAuth

final class MemorialListViewModel: ObservableObject {

    @Published var memorials: [Memorial] = []

    // Estado de carga y error (para la UI)
    @Published var isLoading: Bool = false
    @Published var loadErrorMessage: String? = nil
    @Published var pendingNavigateToMemorial: Memorial? = nil
    @Published var pendingShareTipMemorialId: UUID? = nil

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

    /// Crea memorial, lo añade a la lista y lo guarda en Firestore.
    /// Devuelve el memorial creado para usarlo en onboarding / navegación.
    @discardableResult
    func addMemorial(name: String, petType: PetType, shortQuote: String? = nil) -> Memorial? {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No hay usuario autenticado. No se puede crear memorial.")
            return nil
        }

        // Creamos memorial (asegúrate de que tu createNew admite shortQuote si lo usas)
        var newMemorial = Memorial.createNew(name: name, petType: petType, ownerUid: uid)

        // Si quieres guardar la frase corta del onboarding:
        if let shortQuote, !shortQuote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newMemorial.shortQuote = shortQuote
        }

        memorials.append(newMemorial)
        AnalyticsManager.shared.log(AEvent.memorialCreated, [
            "pet_type": newMemorial.petType.rawValue
        ])
        // 👇 Esto es la “orden” de navegación programática
        pendingNavigateToMemorial = newMemorial
        pendingShareTipMemorialId = newMemorial.id

        Task {
            do {
                try await memorialService.saveMemorial(newMemorial)
                print("✅ Memorial guardado en Firestore con id \(newMemorial.id.uuidString)")
            } catch {
                print("❌ Error al guardar memorial en Firestore: \(error)")
            }
        }

        return newMemorial
    }

    /// Extrae el shareToken a partir de un texto que puede ser:
    /// - un código directo (ej: "AB12CD34")
    /// - una URL que lo contenga al final (ej: "https://huellas.app/m/AB12CD34")
    func extractShareToken(from input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Si parece una URL, intentamos parsearla
        if trimmed.contains("http://") || trimmed.contains("https://") {
            if let url = URL(string: trimmed) {
                let token = url.lastPathComponent
                return token.isEmpty ? nil : token.uppercased()
            } else {
                // Intentamos extraer el último componente "a mano"
                if let last = trimmed.split(separator: "/").last {
                    return String(last).uppercased()
                }
            }
        }

        // Si no es URL, asumimos que es directamente el token
        return trimmed.uppercased()
    }

    /// Intenta unirse a un memorial usando un código o un enlace.
    /// - Devuelve el Memorial si lo encuentra (y lo añade a la lista si no estaba).
    @MainActor
    func joinMemorial(using input: String) async throws -> Memorial {
        guard let token = extractShareToken(from: input) else {
            throw JoinMemorialError.invalidInput
        }

        // Evitar duplicados si ya lo tenemos
        if let existing = memorials.first(where: { $0.shareToken.uppercased() == token }) {
            return existing
        }

        // Llamamos al servicio para buscar en Firestore
        if let found = try await memorialService.fetchMemorial(byShareToken: token) {
            // Lo añadimos a la lista local para que quede guardado
            memorials.append(found)

            AnalyticsManager.shared.log(AEvent.joinMemorial, [
                "result": "success"
            ])

            return found
        } else {
            throw JoinMemorialError.notFound
        }
    }

    enum JoinMemorialError: Error, LocalizedError {
        case invalidInput
        case notFound

        var errorDescription: String? {
            switch self {
            case .invalidInput:
                return "El código o enlace no es válido. Revisa que lo hayas copiado completo."
            case .notFound:
                return "No he encontrado ningún memorial con ese código. Pide a esa persona que te lo vuelva a enviar."
            }
        }
    }
}
