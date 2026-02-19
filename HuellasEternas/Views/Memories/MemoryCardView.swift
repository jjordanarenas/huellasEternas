//
//  MemoryCardView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//

import SwiftUI

struct MemoryCardView: View {
    let memory: Memory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            header

            if let urlString = memory.photoURL, let url = URL(string: urlString) {
                photo(url: url)
            }

            if !memory.text.isEmpty {
                Text(memory.text)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textPrimary)
                    .lineLimit(5)
            }
        }
        .padding(12)
        .background(HuellasColor.card) // ✅ card consistente con el resto
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HuellasColor.divider.opacity(0.9), lineWidth: 1)
        )
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(memory.title.isEmpty ? "Recuerdo" : memory.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(HuellasColor.textPrimary)

            Spacer()

            Text(memory.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(HuellasColor.textSecondary)
        }
    }

    private func photo(url: URL) -> some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                photoPlaceholder(
                    content: AnyView(
                        ProgressView()
                            .tint(HuellasColor.primaryDark)
                    )
                )

            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 220)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(HuellasColor.divider, lineWidth: 1)
                    )
                    .accessibilityLabel("Foto del recuerdo")

            case .failure:
                photoPlaceholder(
                    content: AnyView(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 22))
                                .foregroundStyle(HuellasColor.primaryDark)

                            Text("No se pudo cargar la foto.")
                                .font(.caption)
                                .foregroundStyle(HuellasColor.textSecondary)
                        }
                    )
                )

            @unknown default:
                EmptyView()
            }
        }
    }

    private func photoPlaceholder(content: AnyView) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(HuellasColor.backgroundSecondary) // ✅ nada de blanco
            RoundedRectangle(cornerRadius: 12)
                .stroke(HuellasColor.divider, lineWidth: 1)

            content
        }
        .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 220)
    }
}
