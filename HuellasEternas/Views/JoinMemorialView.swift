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
    @State private var isJoining = false
    @State private var errorMessage: String? = nil

    init(prefilledInput: String = "") {
        _input = State(initialValue: prefilledInput)
    }

    var body: some View {
        Form {
            Section("Código o enlace") {
                TextField("Ej: AB12CD34", text: $input)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
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
                .disabled(isJoining)
            }

            Section {
                Text("Pide a la otra persona que te envíe el código del memorial. Tú solo tienes que pegarlo aquí.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Unirme a un memorial")
    }

    @MainActor
    private func join() async {
        errorMessage = nil
        isJoining = true
        defer { isJoining = false }

        do {
            _ = try await viewModel.joinMemorial(using: input)
            // Si quieres, aquí podríamos disparar navegación automática al memorial unido:
            // viewModel.pendingNavigateToMemorial = memorial
            dismiss()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "No se ha podido unir al memorial."
        }
    }
}
