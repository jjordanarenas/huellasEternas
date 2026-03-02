//
//  MemoryDetailView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 21/2/26.
//


import SwiftUI

struct MemoryDetailView: View {

    let memory: Memory
    @State private var showPhotoViewer = false

    private var titleText: String {
        memory.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? "Recuerdo"
        : memory.title
    }

    var body: some View {
        HuellasScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {

                    header

                    if memory.photoURL != nil {
                        photoPreview
                    }

                    if !memory.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(memory.text)
                            .font(.body)
                            .foregroundStyle(HuellasColor.textPrimary)
                            .padding()
                            .background(HuellasColor.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(HuellasColor.divider, lineWidth: 1)
                            )
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(memory.createdAt.formatted(date: .long, time: .omitted))
                .font(.caption)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var photoPreview: some View {
        if let urlString = memory.photoURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView().tint(HuellasColor.primaryDark)
                        .frame(maxWidth: .infinity, minHeight: 220)

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 260)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(HuellasColor.divider, lineWidth: 1)
                        )
                        .onTapGesture { showPhotoViewer = true }

                case .failure:
                    Text("No se pudo cargar la foto.")
                        .font(.caption)
                        .foregroundStyle(HuellasColor.textSecondary)

                @unknown default:
                    EmptyView()
                }
            }
            .sheet(isPresented: $showPhotoViewer) {
                PhotoViewerView(memory: memory)
            }
        }
    }
}
