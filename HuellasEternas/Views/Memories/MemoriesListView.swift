//
//  MemoriesListView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 19/2/26.
//

import SwiftUI

struct MemoriesListView: View {

    @ObservedObject var memoriesVM: MemoriesViewModel
    @State private var confirmDelete: Memory? = nil

    var body: some View {
        HuellasListContainer {
            ZStack(alignment: .bottom) {

                List {
                    if memoriesVM.memories.isEmpty {
                        ContentUnavailableView(
                            "Aún no hay recuerdos",
                            systemImage: "photo.on.rectangle",
                            description: Text("Añade fotos, anécdotas y momentos especiales.")
                        )
                        .foregroundStyle(HuellasColor.textPrimary)
                        .listRowBackground(HuellasColor.background) // ✅
                    } else {
                        ForEach(memoriesVM.memories) { memory in
                            MemoryCardView(memory: memory)
                                .listRowBackground(HuellasColor.card)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        confirmDelete = memory
                                    } label: {
                                        Label("Borrar", systemImage: "trash")
                                    }
                                    .tint(.red) // ✅ (el rojo del sistema está bien para destructive)
                                }
                        }
                    }
                }
                .listRowSeparatorTint(HuellasColor.divider)
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)                 // ✅ evita blanco del List
                .background(HuellasColor.background)              // ✅ refuerzo
                .navigationTitle("Recuerdos")
                .navigationBarTitleDisplayMode(.inline)
                .tint(HuellasColor.primaryDark)                   // ✅ acento consistente
                .alert(item: $confirmDelete) { memory in
                    Alert(
                        title: Text("Borrar recuerdo"),
                        message: Text("¿Seguro que quieres borrar este recuerdo? Esta acción no se puede deshacer."),
                        primaryButton: .destructive(Text("Borrar")) {
                            memoriesVM.requestDeleteWithUndo(memory: memory)
                        },
                        secondaryButton: .cancel(Text("Cancelar"))
                    )
                }

                // Snackbar UNDO
                if memoriesVM.undoBannerVisible, let _ = memoriesVM.pendingUndoMemory {
                    UndoBanner(
                        text: "Recuerdo eliminado",
                        actionTitle: "Deshacer",
                        onAction: { memoriesVM.undoDelete() }
                    )
                    .padding(.bottom, 14)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(HuellasColor.background) // ✅ por si el ZStack deja huecos
        }
    }
}

// MARK: - Undo Banner

private struct UndoBanner: View {
    let text: String
    let actionTitle: String
    let onAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textPrimary)

            Spacer()

            Button(actionTitle) { onAction() }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(HuellasColor.primaryDark)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
