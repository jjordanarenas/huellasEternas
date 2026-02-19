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
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(memory.title.isEmpty ? "Recuerdo" : memory.title)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()

                Text(memory.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(HuellasColor.textSecondary)
            }

            if let urlString = memory.photoURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().tint(HuellasColor.primaryDark)
                            .frame(maxWidth: .infinity, minHeight: 140)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 200)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(HuellasColor.divider, lineWidth: 1)
                            )
                    case .failure:
                        Text("No se pudo cargar la foto.")
                            .font(.caption)
                            .foregroundStyle(HuellasColor.textSecondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            if !memory.text.isEmpty {
                Text(memory.text)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textPrimary)
                    .lineLimit(5)
            }
        }
        .padding(12)
        .background(HuellasColor.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HuellasColor.divider.opacity(0.8), lineWidth: 1)
        )
    }
}
