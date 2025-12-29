//
//  JoinMemorialView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/12/25.
//

import SwiftUI

struct JoinMemorialView: View {
    @EnvironmentObject var viewModel: MemorialListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var input: String
    @State private var isJoining: Bool = false
    @State private var errorMessage: String? = nil

    /// Permite abrir esta pantalla con un texto ya pegado (opcional).
    init(prefilledInput: String = "") {
        _input = State(initialValue: prefilledInput)
    }

    var body: some View {
        Form {
            Section("Código o enlace") {
                TextField("Pega aquí el código o el enlace", text: $input, axis: .vertical)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .lineLimit(3, reservesSpace: true)

                Text("Ejemplo: AB12CD34")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }

            Section {
                Button {
                    Task { await join() }
                } label: {
                    if isJoining {
                        HStack {
                            ProgressView()
                            Text("Uniéndome…")
                        }
                    } else {
                        Text("Unirme")
                    }
                }
                .disabled(isJoining || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Unirme")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cerrar") { dismiss() }
            }
        }
    }

    @MainActor
    private func join() async {
        errorMessage = nil
        isJoining = true

        do {
            let memorial = try await viewModel.joinMemorial(using: input)

            // ✅ Navegación automática al memorial unido
            viewModel.pendingNavigateToMemorial = memorial

            // Cerramos la pantalla de unirse (volverás a la lista,
            // y la lista empuja al detalle con tu NavigationPath)
            dismiss()

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "No se ha podido unir al memorial."
        }

        isJoining = false
    }
}
