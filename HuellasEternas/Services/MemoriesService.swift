//
//  MemoriesService.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

final class MemoriesService {

    enum MemoriesError: LocalizedError {
        case freePhotoLimitReached
        var errorDescription: String? {
            switch self {
            case .freePhotoLimitReached:
                return "Has alcanzado el límite de fotos en este memorial."
            }
        }
    }

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private func memoriesRef(memorialId: String) -> CollectionReference {
        db.collection("memorials").document(memorialId).collection("memories")
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
            let photoPath = data["photoPath"] as? String
            let ts = data["createdAt"] as? Timestamp
            let createdAt = ts?.dateValue() ?? Date()

            return Memory(
                id: doc.documentID,
                title: title,
                text: text,
                photoURL: photoURL,
                photoPath: photoPath,
                createdAt: createdAt
            )
        }
    }

    func addMemory(
        memorialId: String,
        title: String,
        text: String,
        photoData: Data?,
        isPremium: Bool
    ) async throws {

        var uploadedPhotoURL: String? = nil
        var uploadedPhotoPath: String? = nil

        if let photoData {
            // ✅ límite de 5 fotos por memorial para free
            if !isPremium {
                let snap = try await memoriesRef(memorialId: memorialId)
                    .whereField("photoPath", isNotEqualTo: NSNull()) // solo con foto
                    .getDocuments()
                if snap.count >= 5 {
                    throw MemoriesError.freePhotoLimitReached
                }
            }

            let result = try await uploadPhoto(memorialId: memorialId, data: photoData)
            uploadedPhotoURL = result.url
            uploadedPhotoPath = result.path
        }

        let memoryId = UUID().uuidString
        let payload: [String: Any] = [
            "title": title,
            "text": text,
            "photoURL": uploadedPhotoURL as Any,
            "photoPath": uploadedPhotoPath as Any,
            "createdAt": Timestamp(date: Date())
        ]

        try await memoriesRef(memorialId: memorialId)
            .document(memoryId)
            .setData(payload)
    }

    func deleteMemory(memorialId: String, memory: Memory) async throws {
        // 1) Borra el doc
        try await memoriesRef(memorialId: memorialId)
            .document(memory.id)
            .delete()

        // 2) Borra la foto si existe (mejor esfuerzo)
        if let path = memory.photoPath, !path.isEmpty {
            let ref = storage.reference(withPath: path)
            do {
                try await ref.delete()
            } catch {
                // No bloqueamos el borrado del recuerdo si falla la foto.
                print("⚠️ No se pudo borrar la foto en Storage:", error)
            }
        }
    }

    private func uploadPhoto(memorialId: String, data: Data) async throws -> (url: String, path: String) {
        let path = "memorials/\(memorialId)/memories/\(UUID().uuidString).jpg"
        let ref = storage.reference(withPath: path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" // ✅ clave para tus reglas

        _ = try await ref.putDataAsync(data, metadata: metadata)
        let url = try await ref.downloadURL()
        return (url.absoluteString, path)
    }
}
