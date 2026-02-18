//
//  MemoriesService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//


import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

final class MemoriesService {

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // ✅ Límite de fotos (solo Free)
    private let freePhotoLimitPerMemorial = 5

    private func memoriesRef(memorialId: String) -> CollectionReference {
        db.collection("memorials").document(memorialId).collection("memories")
    }

    // ✅ Cuenta cuántas memories con foto hay (rápido: query)
    private func photoMemoriesCount(memorialId: String) async throws -> Int {
        let snap = try await memoriesRef(memorialId: memorialId)
            .whereField("photoURL", isNotEqualTo: NSNull())
            .getDocuments()
        return snap.documents.count
    }

    func fetchMemories(memorialId: String) async throws -> [Memory] {
        let snap = try await memoriesRef(memorialId: memorialId)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snap.documents.compactMap { doc in
            let data = doc.data()
            let title = data["title"] as? String ?? ""
            let text = data["text"] as? String ?? ""
            let photoURL = data["photoURL"] as? String
            let ts = data["createdAt"] as? Timestamp
            let createdAt = ts?.dateValue() ?? Date()

            return Memory(id: doc.documentID, title: title, text: text, photoURL: photoURL, createdAt: createdAt)
        }
    }

    /// ✅ Nuevo: `isPremium` para decidir límites
    func addMemory(
        memorialId: String,
        title: String,
        text: String,
        photoData: Data?,
        isPremium: Bool,
        currentPhotoCount: Int // ✅ lo pasamos desde VM para no re-consultar aquí
    ) async throws {

        // Límite para free (ajústalo)
        let freePhotoLimit = 3

        if !isPremium, photoData != nil, currentPhotoCount >= freePhotoLimit {
            throw MemoriesError.freePhotoLimitReached(limit: freePhotoLimit)
        }

        var uploadedPhotoURL: String? = nil

        if let photoData {
            // ✅ Comprime antes de subir (clave para costes y UX)
            let compressed = try ImageCompressor.compressToJPEG(data: photoData)
            uploadedPhotoURL = try await uploadPhoto(memorialId: memorialId, data: compressed)
        }

        let memoryId = UUID().uuidString
        let payload: [String: Any] = [
            "title": title,
            "text": text,
            "photoURL": uploadedPhotoURL as Any,
            "createdAt": Timestamp(date: Date())
        ]

        try await memoriesRef(memorialId: memorialId)
            .document(memoryId)
            .setData(payload)
    }

    func deleteMemory(memorialId: String, memory: Memory) async throws {
        // Si quieres: borrar también el archivo en Storage.
        try await memoriesRef(memorialId: memorialId)
            .document(memory.id)
            .delete()
    }

    private func uploadPhoto(memorialId: String, data: Data) async throws -> String {
        let path = "memorials/\(memorialId)/memories/\(UUID().uuidString).jpg"
        let ref = storage.reference(withPath: path)

        // ✅ metadata (contentType correcto)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}

// ✅ Errores “bonitos” para UI
extension MemoriesService {
    enum MemoriesError: LocalizedError {
        case freePhotoLimitReached(limit: Int)

        var errorDescription: String? {
            switch self {
            case .freePhotoLimitReached(let limit):
                return "Has llegado al límite de \(limit) recuerdos con foto. Hazte Premium para añadir más."
            }
        }
    }
}
