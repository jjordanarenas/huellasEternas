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
    @Published var archivedMemorials: [Memorial] = []

    // Servicio para Firestore
    private let memorialService: MemorialService
    private let orderService = MemorialOrderService()
    private var orderItems: [MemorialOrderItem] = []
    private var relationshipById: [String: Relationship] = [:]

    init(memorialService: MemorialService = MemorialService()) {
        self.memorialService = memorialService

        // Nada más crearse el ViewModel, cargamos memoriales de Firestore
        Task {
            await loadMemorials()
        }
    }

    // MARK: - Cargar memoriales desde Firestore

    /// Carga todos los memoriales desde Firestore y actualiza la lista
    @MainActor
    func loadMemorials() async {
        guard !isLoading else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            loadErrorMessage = "No hay sesión iniciada."
            return
        }

        isLoading = true
        loadErrorMessage = nil
        defer { isLoading = false }

        do {
            let fetchedOrderItems = try await orderService.fetchOrder()

            // ✅ guarda el orden en memoria (tu archive() lo usa)
            self.orderItems = fetchedOrderItems

            // ✅ Si aún no hay orden, NO traigas todo: trae solo los del owner
            if fetchedOrderItems.isEmpty {

                let owned = try await memorialService.fetchOwnedMemorials(ownerUid: uid)

                // Orden razonable para el primer arranque (por fecha)
                let sortedOwned = owned.sorted { $0.createdAt > $1.createdAt }

                self.memorials = sortedOwned
                self.archivedMemorials = []

                // ✅ (Recomendado) Seed del orden en background para que ya quede persistido
                // y no vuelvas a caer en "empty order" en próximos arranques.
                Task {
                    do {
                        // Si tu OrderService tiene bulkUpsert mejor; si no, uno a uno:
                        for (idx, m) in sortedOwned.enumerated() {
                            try await orderService.upsert(
                                memorialId: m.id.uuidString,
                                relationship: .owned,
                                sortIndex: idx
                            )
                        }
                    } catch {
                        print("❌ Error haciendo seed del orden: \(error)")
                    }
                }

                return
            }

            // ✅ Caso normal: hay orden -> cargamos exactamente esos IDs
            let orderedIds = fetchedOrderItems.map { $0.memorialId }
            let fetched = try await memorialService.fetchMemorials(byIds: orderedIds)

            let byId = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id.uuidString, $0) })

            let activeIds = fetchedOrderItems.filter { !$0.isArchived }.map { $0.memorialId }
            let archivedIds = fetchedOrderItems.filter { $0.isArchived }.map { $0.memorialId }

            self.memorials = activeIds.compactMap { byId[$0] }
            self.archivedMemorials = archivedIds.compactMap { byId[$0] }

        } catch {
            print("❌ Error al cargar memoriales: \(error)")
            self.loadErrorMessage = "No se han podido cargar tus memoriales."
        }
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

        Task {
            do {
                try await orderService.upsert(
                    memorialId: newMemorial.id.uuidString,
                    relationship: .owned,
                    sortIndex: memorials.count - 1
                )
            } catch {
                print("❌ Error guardando orden (owned): \(error)")
            }
        }

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
        let normalized = token.uppercased()

        if let existing = (memorials + archivedMemorials)
            .first(where: { $0.shareToken.uppercased() == normalized }) {
            return existing
        }

        if let found = try await memorialService.fetchMemorial(byShareToken: normalized) {

            memorials.append(found)

            // ✅ también actualiza orderItems en memoria (para que archive/restore vaya fino sin reload)
            orderItems.append(
                MemorialOrderItem(
                    memorialId: found.id.uuidString,
                    relationship: .joined,
                    isArchived: false
                )
            )

            Task {
                do {
                    try await orderService.upsert(
                        memorialId: found.id.uuidString,
                        relationship: .joined,
                        sortIndex: memorials.count - 1
                    )
                } catch {
                    print("❌ Error guardando orden (joined): \(error)")
                }
            }

            return found
        } else {
            throw JoinMemorialError.notFound
        }
    }
    
    func moveMemorials(from source: IndexSet, to destination: Int) {
        memorials.move(fromOffsets: source, toOffset: destination)

        // Relación por id (owned/joined) para guardar en Firestore
        let uid = Auth.auth().currentUser?.uid
        let relById: [String: Relationship] = Dictionary(
            uniqueKeysWithValues: memorials.map { m in
                let rel: Relationship = (uid != nil && m.ownerUid == uid) ? .owned : .joined
                return (m.id.uuidString, rel)
            }
        )

        let idsInOrder = memorials.map { $0.id.uuidString }

        Task {
            do {
                try await orderService.saveFullOrder(memorialIdsInOrder: idsInOrder, relationshipById: relById)
            } catch {
                print("❌ Error guardando reorder: \(error)")
            }
        }
    }

    @MainActor
    func archive(_ memorial: Memorial) async {
        let id = memorial.id.uuidString

        // 1) UI optimista: mover de activos -> archivados (sin recargar)
        if let idx = memorials.firstIndex(where: { $0.id == memorial.id }) {
            let moved = memorials.remove(at: idx)
            archivedMemorials.append(moved)
        }

        // 2) Actualiza el estado en memoria del orden global
        if let oi = orderItems.firstIndex(where: { $0.memorialId == id }) {
            let old = orderItems[oi]
            orderItems[oi] = MemorialOrderItem(
                memorialId: old.memorialId,
                relationship: old.relationship,
                isArchived: true
            )
        }

        // 3) Persistir en Firestore
        do {
            try await orderService.setArchived(memorialId: id, isArchived: true)
            // ✅ NO hacemos loadMemorials aquí -> evita el crash durante el swipe
        } catch {
            print("❌ Error archivando memorial: \(error)")
            // En caso de error, recargamos para “curarnos” y volver a estado consistente
            await loadMemorials()
        }
    }

    @MainActor
    func restore(_ memorial: Memorial) async {
        let id = memorial.id.uuidString

        // 1) UI optimista: mover de archivados -> activos
        if let idx = archivedMemorials.firstIndex(where: { $0.id == memorial.id }) {
            let moved = archivedMemorials.remove(at: idx)
            memorials.append(moved)
        }

        // 2) Orden global en memoria
        if let oi = orderItems.firstIndex(where: { $0.memorialId == id }) {
            let old = orderItems[oi]
            orderItems[oi] = MemorialOrderItem(
                memorialId: old.memorialId,
                relationship: old.relationship,
                isArchived: false
            )
        }

        // 3) Persistir
        do {
            try await orderService.setArchived(memorialId: id, isArchived: false)
        } catch {
            print("❌ Error restaurando memorial: \(error)")
            await loadMemorials()
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
