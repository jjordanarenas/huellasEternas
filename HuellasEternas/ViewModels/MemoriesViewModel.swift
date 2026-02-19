//
//  MemoriesViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//

import Foundation
import SwiftUI

@MainActor
final class MemoriesViewModel: ObservableObject {

    @Published var memories: [Memory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var shouldShowPaywall: Bool = false

    // ✅ Undo state
    @Published var undoBannerVisible: Bool = false
    @Published var pendingUndoMemory: Memory? = nil

    private var pendingUndoIndex: Int? = nil
    private var commitDeleteTask: Task<Void, Never>? = nil

    private let service = MemoriesService()
    private let memorialId: String

    init(memorialId: String) {
        self.memorialId = memorialId
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            memories = try await service.fetchMemories(memorialId: memorialId)
        } catch {
            errorMessage = "No se han podido cargar los recuerdos."
        }
    }

    func add(title: String, text: String, photoData: Data?) async -> Bool {
        errorMessage = nil
        shouldShowPaywall = false

        do {
            try await service.addMemory(
                memorialId: memorialId,
                title: title,
                text: text,
                photoData: photoData,
                isPremium: SubscriptionManager.shared.isPremium
            )
            memories = try await service.fetchMemories(memorialId: memorialId)
            return true
        } catch let e as MemoriesService.MemoriesError {
            errorMessage = e.localizedDescription
            shouldShowPaywall = true
            return false
        } catch {
            print("❌ addMemory error:", error)
            errorMessage = "No se ha podido guardar el recuerdo."
            return false
        }
    }

    // MARK: - Delete with Undo (3s)

    func requestDeleteWithUndo(memory: Memory) {
        errorMessage = nil

        // Cancela un delete pendiente anterior, si existía
        commitDeleteTask?.cancel()
        commitDeleteTask = nil

        guard let idx = memories.firstIndex(where: { $0.id == memory.id }) else { return }

        // Quitamos de UI inmediatamente
        pendingUndoMemory = memory
        pendingUndoIndex = idx
        memories.remove(at: idx)

        // Mostramos banner
        withAnimation(.easeInOut) {
            undoBannerVisible = true
        }

        // Programamos commit real en 3s
        commitDeleteTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 3_000_000_000)

            // Si el usuario no deshizo
            guard !Task.isCancelled else { return }
            guard let toDelete = self.pendingUndoMemory else { return }

            do {
                try await self.service.deleteMemory(memorialId: self.memorialId, memory: toDelete)
            } catch {
                // Si falla, reinsertamos para no "perder" en UI
                if let insertIndex = self.pendingUndoIndex {
                    self.memories.insert(toDelete, at: min(insertIndex, self.memories.count))
                } else {
                    self.memories.insert(toDelete, at: 0)
                }
                self.errorMessage = "No se ha podido borrar el recuerdo."
            }

            // Limpieza estado
            await MainActor.run {
                self.clearUndoState()
            }
        }
    }

    func undoDelete() {
        commitDeleteTask?.cancel()
        commitDeleteTask = nil

        guard let memory = pendingUndoMemory else { return }

        if let idx = pendingUndoIndex {
            memories.insert(memory, at: min(idx, memories.count))
        } else {
            memories.insert(memory, at: 0)
        }

        clearUndoState()
    }

    private func clearUndoState() {
        withAnimation(.easeInOut) {
            undoBannerVisible = false
        }
        pendingUndoMemory = nil
        pendingUndoIndex = nil
    }
}
