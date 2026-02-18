//
//  AddMemoryView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 14/2/26.
//


import SwiftUI
import PhotosUI

struct AddMemoryView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var text: String = ""

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    @State private var isSaving = false
    @State private var showErrorAlert = false
    @State private var errorText = "No se ha podido guardar el recuerdo."

    /// ✅ Ahora devuelve Bool (true = ok)
    let onSave: (String, String, Data?) async -> Bool

    private var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var canSave: Bool {
        !isSaving && (!trimmedTitle.isEmpty || !trimmedText.isEmpty || selectedImageData != nil)
    }

    var body: some View {
        NavigationStack {
            HuellasListContainer {
                Form {
                    Section("Título (opcional)") {
                        TextField("Ej: Su paseo favorito", text: $title)
                            .foregroundStyle(HuellasColor.textPrimary)
                    }
                    .listRowBackground(HuellasColor.card)

                    Section("Anécdota / momento") {
                        TextEditor(text: $text)
                            .frame(minHeight: 140)
                            .foregroundStyle(HuellasColor.textPrimary)
                            .scrollContentBackground(.hidden)
                    }
                    .listRowBackground(HuellasColor.card)

                    Section("Foto (opcional)") {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Elegir foto", systemImage: "photo")
                                .foregroundStyle(HuellasColor.textPrimary)
                        }
                        .tint(HuellasColor.primaryDark)

                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(HuellasColor.divider, lineWidth: 1)
                                )
                                .padding(.top, 8)
                        }
                    }
                    .listRowBackground(HuellasColor.card)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Nuevo recuerdo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                            .foregroundStyle(HuellasColor.primaryDark)
                            .disabled(isSaving)
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button(isSaving ? "Guardando…" : "Guardar") {
                            Task { await saveTapped() }
                        }
                        .foregroundStyle(HuellasColor.primaryDark)
                        .disabled(!canSave)
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            await MainActor.run { selectedImageData = data }
                        }
                    }
                }
                .alert("No se pudo guardar", isPresented: $showErrorAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(errorText)
                }
            }
        }
    }

    @MainActor
    private func saveTapped() async {
        guard canSave else { return }
        isSaving = true

        let ok = await onSave(trimmedTitle, trimmedText, selectedImageData)

        isSaving = false

        if ok {
            dismiss()
        } else {
            // El VM ya habrá puesto errorMessage, pero aquí mostramos algo genérico.
            errorText = "Revisa tu conexión o prueba de nuevo."
            showErrorAlert = true
        }
    }
}
