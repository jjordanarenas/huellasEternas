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
        case freePhotoLimitReached(max: Int)
        case invalidImage
        case imageTooLarge

        var errorDescription: String? {
            switch self {
            case .freePhotoLimitReached(let max):
                return "Has alcanzado el límite de \(max) fotos en recuerdos para este memorial. Hazte Premium para añadir más."
            case .invalidImage:
                return "No se ha podido leer la imagen seleccionada."
            case .imageTooLarge:
                return "La imagen es demasiado grande. Prueba con otra o recórtala."
            }
        }
    }

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // ✅ Ajusta aquí el límite Free
    private let freeMaxPhotosPerMemorial = 5

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
            let ts = data["createdAt"] as? Timestamp
            let createdAt = ts?.dateValue() ?? Date()

            return Memory(id: doc.documentID, title: title, text: text, photoURL: photoURL, createdAt: createdAt)
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

        if let photoData {
            // ✅ Límite Free (solo si intenta subir foto)
            if !isPremium {
                let count = try await countMemoriesWithPhoto(memorialId: memorialId)
                if count >= freeMaxPhotosPerMemorial {
                    throw MemoriesError.freePhotoLimitReached(max: freeMaxPhotosPerMemorial)
                }
            }

            // ✅ Compresión + JPEG
            let jpegData: Data
            do {
                jpegData = try ImageCompressor.compressToJPEG(photoData)
            } catch {
                // mapeo de errores a algo entendible
                if (error as? ImageCompressor.CompressionError) == .invalidImageData {
                    throw MemoriesError.invalidImage
                } else if (error as? ImageCompressor.CompressionError) == .tooLargeEvenAfterCompression {
                    throw MemoriesError.imageTooLarge
                } else {
                    throw MemoriesError.invalidImage
                }
            }

            uploadedPhotoURL = try await uploadPhoto(memorialId: memorialId, jpegData: jpegData)
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
        try await memoriesRef(memorialId: memorialId)
            .document(memory.id)
            .delete()
    }

    // MARK: - Free limit helper

    /// Cuenta recuerdos que tienen foto (photoURL no vacío)
    private func countMemoriesWithPhoto(memorialId: String) async throws -> Int {
        let snap = try await memoriesRef(memorialId: memorialId)
            .whereField("photoURL", isNotEqualTo: NSNull())
            .getDocuments()

        // Nota: Firestore con isNotEqualTo puede devolver también docs sin el campo en algunos casos;
        // si quieres ser ultra-seguro:
        return snap.documents.filter { doc in
            let url = doc.data()["photoURL"] as? String
            return (url?.isEmpty == false)
        }.count
    }

    // MARK: - Storage

    private func uploadPhoto(memorialId: String, jpegData: Data) async throws -> String {
        let path = "memorials/\(memorialId)/memories/\(UUID().uuidString).jpg"
        let ref = storage.reference(withPath: path)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"   // ✅ CLAVE (ya lo viste)

        _ = try await ref.putDataAsync(jpegData, metadata: metadata)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
