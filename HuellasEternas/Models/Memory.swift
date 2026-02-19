//
//  Memory.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//


import Foundation
import FirebaseFirestore

struct Memory: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var text: String
    var photoURL: String?
    var photoPath: String?     // ✅ NUEVO
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        text: String,
        photoURL: String? = nil,
        photoPath: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.photoURL = photoURL
        self.photoPath = photoPath
        self.createdAt = createdAt
    }
}
