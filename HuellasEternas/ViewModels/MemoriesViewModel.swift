//
//  MemoriesViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//

import Foundation

@MainActor
final class MemoriesViewModel: ObservableObject {

    @Published var memories: [Memory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var shouldShowPaywall: Bool = false

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

    private var currentPhotoCount: Int {
        memories.filter { ($0.photoURL?.isEmpty == false) }.count
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
                isPremium: SubscriptionManager.shared.isPremium,
                currentPhotoCount: currentPhotoCount
            )

            memories = try await service.fetchMemories(memorialId: memorialId)
            return true

        } catch let e as MemoriesService.MemoriesError {
            errorMessage = e.localizedDescription
            shouldShowPaywall = true
            return false

        } catch let e as ImageCompressor.CompressionError {
            errorMessage = e.localizedDescription
            return false

        } catch {
            print("❌ addMemory error:", error)
            errorMessage = "No se ha podido guardar el recuerdo."
            return false
        }
    }

    func delete(memory: Memory) async {
        errorMessage = nil
        do {
            try await service.deleteMemory(memorialId: memorialId, memory: memory)
            memories.removeAll { $0.id == memory.id }
        } catch {
            errorMessage = "No se ha podido borrar el recuerdo."
        }
    }
}
