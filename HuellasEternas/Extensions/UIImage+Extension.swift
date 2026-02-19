//
//  UIImage+Extension.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 17/2/26.
//

import UIKit

enum ImageProcessing {

    /// Redimensiona y comprime la imagen para subirla a Storage.
    /// - maxDimension: máximo ancho/alto (ej 1600)
    /// - quality: 0...1 (ej 0.72)
    static func prepareForUpload(_ data: Data,
                                 maxDimension: CGFloat = 1600,
                                 quality: CGFloat = 0.72) throws -> Data {

        guard let image = UIImage(data: data) else {
            throw ProcessingError.invalidImageData
        }

        let resized = image.resized(maxDimension: maxDimension)

        // JPEG (más compatible y barato)
        if let jpeg = resized.jpegData(compressionQuality: quality) {
            return jpeg
        }

        throw ProcessingError.couldNotCompress
    }

    enum ProcessingError: LocalizedError {
        case invalidImageData
        case couldNotCompress

        var errorDescription: String? {
            switch self {
            case .invalidImageData: return "La imagen no es válida."
            case .couldNotCompress: return "No se pudo comprimir la imagen."
            }
        }
    }
}

private extension UIImage {

    func resized(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1 // importante: controlas tú el tamaño real
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
