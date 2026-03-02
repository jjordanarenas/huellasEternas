//
//  PhotoViewerView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 19/2/26.
//

import SwiftUI

struct PhotoViewerView: View {

    @Environment(\.dismiss) private var dismiss
    let memory: Memory

    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private var titleText: String {
        memory.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "Recuerdo"
        : memory.title
    }

    private var dateText: String {
        memory.createdAt.formatted(date: .long, time: .omitted)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HuellasColor.background

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        // Header “bonito”
                        VStack(alignment: .leading, spacing: 6) {
                            Text(titleText)
                                .font(.title3)
                                .bold()
                                .foregroundStyle(HuellasColor.textPrimary)

                            Text(dateText)
                                .font(.caption)
                                .foregroundStyle(HuellasColor.textSecondary)
                        }
                        .padding(.top, 6)

                        // Imagen con zoom/pan
                        photoContent
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(HuellasColor.divider, lineWidth: 1)
                            )

                        // Texto debajo (si existe)
                        if !memory.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción")
                                    .font(.headline)
                                    .foregroundStyle(HuellasColor.textPrimary)

                                Text(memory.text)
                                    .font(.subheadline)
                                    .foregroundStyle(HuellasColor.textPrimary)
                            }
                            .padding()
                            .background(HuellasColor.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(HuellasColor.divider, lineWidth: 1)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(HuellasColor.primaryDark)
                }

                // Share opcional: comparte texto (si quieres, luego hacemos share “real” de la imagen)
                ToolbarItem(placement: .topBarLeading) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(HuellasColor.primaryDark)
                    }
                    .accessibilityLabel("Compartir")
                }
            }
        }
    }

    private var shareText: String {
        var parts: [String] = [titleText, dateText]
        let body = memory.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !body.isEmpty { parts.append(body) }
        return parts.joined(separator: "\n\n")
    }

    @ViewBuilder
    private var photoContent: some View {
        if let urlString = memory.photoURL, let url = URL(string: urlString) {
            AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                switch phase {
                case .empty:
                    VStack(spacing: 10) {
                        ProgressView()
                            .tint(HuellasColor.primaryDark)
                        Text("Cargando foto…")
                            .font(.subheadline)
                            .foregroundStyle(HuellasColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(zoomGesture.simultaneously(with: panGesture))
                        .onTapGesture(count: 2) { resetZoomAnimated() }
                        .frame(maxWidth: .infinity, minHeight: 260)
                        .background(HuellasColor.backgroundSecondary)
                        .contentShape(Rectangle())

                case .failure:
                    VStack(spacing: 10) {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(HuellasColor.primaryDark)
                        Text("No se pudo cargar la foto.")
                            .font(.subheadline)
                            .foregroundStyle(HuellasColor.textSecondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260)

                @unknown default:
                    EmptyView()
                }
            }
        } else {
            VStack(spacing: 10) {
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(HuellasColor.primaryDark)
                Text("Este recuerdo no tiene foto.")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 260)
            .background(HuellasColor.backgroundSecondary)
        }
    }

    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, 1), 5)
            }
            .onEnded { _ in
                lastScale = scale
                if scale <= 1.01 { resetPanAnimated() }
            }
    }

    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard scale > 1 else { return }
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private func resetZoomAnimated() {
        withAnimation(.easeInOut) {
            scale = 1
            lastScale = 1
            offset = .zero
            lastOffset = .zero
        }
    }

    private func resetPanAnimated() {
        withAnimation(.easeInOut) {
            offset = .zero
            lastOffset = .zero
        }
    }
}
