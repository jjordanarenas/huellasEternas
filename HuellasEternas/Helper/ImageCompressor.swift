//
//  ImageCompressor.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/2/26.
//


import Foundation
import UIKit

enum ImageCompressor {

    /*struct Config {
        var maxDimension: CGFloat = 1600        // px (lado largo)
        var initialJPEGQuality: CGFloat = 0.80
        var minJPEGQuality: CGFloat = 0.45
        var maxBytes: Int = 900_000             // ~0.9MB (ajusta si quieres)
        var qualityStep: CGFloat = 0.08
    }*/

    /*static func compressToJPEG(data: Data, config: Config = .init()) throws -> Data {
        guard let image = UIImage(data: data) else {
            throw CompressionError.invalidImageData
        }

        let resized = resize(image: image, maxDimension: config.maxDimension)

        var quality = config.initialJPEGQuality
        var jpeg = resized.jpegData(compressionQuality: quality)

        guard jpeg != nil else {
            throw CompressionError.couldNotEncodeJPEG
        }

        // Baja la calidad hasta cumplir tamaño (o llegar al mínimo).
        while let current = jpeg,
              current.count > config.maxBytes,
              quality > config.minJPEGQuality {

            quality = max(config.minJPEGQuality, quality - config.qualityStep)
            jpeg = resized.jpegData(compressionQuality: quality)
        }

        guard let final = jpeg else {
            throw CompressionError.couldNotEncodeJPEG
        }

        return final
    }*/

    private static func resize(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)

        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1 // para controlar tamaño final

        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /*enum CompressionError: LocalizedError {
        case invalidImageData
        case couldNotEncodeJPEG

        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "La imagen no es válida."
            case .couldNotEncodeJPEG:
                return "No se pudo procesar la imagen."
            }
        }
    }*/
}

extension ImageCompressor {

    struct Config {
        /// Lado máximo (px) del resultado (ej: 1600 = suficiente para móvil, barato en Storage)
        var maxDimension: CGFloat = 1600
        /// Calidad JPEG (0...1). 0.72–0.80 suele ser muy buen tradeoff
        var jpegQuality: CGFloat = 0.78
        /// Tamaño máximo tras compresión (bytes). Si lo supera, baja calidad en pasos.
        var maxBytes: Int = 1_200_000 // ~1.2MB
        /// Calidad mínima a la que permitimos bajar
        var minQuality: CGFloat = 0.55
        /// Paso de decremento de calidad
        var qualityStep: CGFloat = 0.07
    }

    enum CompressionError: Error {
        case invalidImageData
        case cannotCreateJPEG
        case tooLargeEvenAfterCompression
    }

    /// Devuelve data JPEG lista para subir (ya comprimida y con tamaño razonable)
    static func compressToJPEG(_ data: Data, config: Config = Config()) throws -> Data {
        guard let image = UIImage(data: data) else {
            throw CompressionError.invalidImageData
        }

        let resized = resizeIfNeeded(image, maxDimension: config.maxDimension)

        var quality = config.jpegQuality
        guard var jpeg = resized.jpegData(compressionQuality: quality) else {
            throw CompressionError.cannotCreateJPEG
        }

        // Si sigue siendo grande, bajamos calidad progresivamente
        while jpeg.count > config.maxBytes && quality > config.minQuality {
            quality = max(config.minQuality, quality - config.qualityStep)
            if let next = resized.jpegData(compressionQuality: quality) {
                jpeg = next
            } else {
                throw CompressionError.cannotCreateJPEG
            }
        }

        if jpeg.count > config.maxBytes {
            throw CompressionError.tooLargeEvenAfterCompression
        }

        return jpeg
    }

    private static func resizeIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
