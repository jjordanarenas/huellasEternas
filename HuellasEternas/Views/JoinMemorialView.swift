//
//  JoinMemorialView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/12/25.
//

import SwiftUI
import UIKit

struct JoinMemorialView: View {

    @EnvironmentObject var viewModel: MemorialListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var input: String
    @State private var isJoining: Bool = false
    @State private var errorMessage: String? = nil

    // Para evitar que el auto-join se dispare más de una vez
    @State private var didAutoJoin: Bool = false
    @State private var toast: Toast? = nil

    // Si quieres auto-join cuando llegue prefilled (por ejemplo desde un universal link futuro)
    private let shouldAutoJoinOnAppear: Bool

    init(prefilledInput: String = "", autoJoinOnAppear: Bool = true) {
        _input = State(initialValue: prefilledInput)
        self.shouldAutoJoinOnAppear = autoJoinOnAppear
    }

    private var trimmedInput: String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canJoin: Bool {
        !isJoining && !trimmedInput.isEmpty
    }

    private var clipboardText: String {
        UIPasteboard.general.string ?? ""
    }

    private var hasClipboardText: Bool {
        !clipboardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section("Código o enlace") {
                TextField("Pega el código o el enlace", text: $input)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .onSubmit {
                        Task { await joinTapped() }
                    }

                HStack {
                    Button {
                        pasteFromClipboardAndNormalize()
                    } label: {
                        Label("Pegar", systemImage: "doc.on.clipboard")
                    }
                    .disabled(!hasClipboardText || isJoining)

                    Spacer()

                    Button {
                        normalizeInput()
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        Label("Normalizar", systemImage: "wand.and.stars")
                    }
                    .foregroundColor(.secondary)
                    .disabled(trimmedInput.isEmpty || isJoining)
                }
            }

            if let errorMessage {
                Section {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 6)
                }
            }

            Section {
                Button {
                    Task { await joinTapped() }
                } label: {
                    HStack {
                        if isJoining { ProgressView() }
                        Text(isJoining ? "Uniéndome…" : "Unirme")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(!canJoin)
            }

            Section {
                Text("Tip: si te mandan un enlace, puedes pegarlo aquí. La app extraerá el código automáticamente.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Unirme")
        .onAppear {
            guard shouldAutoJoinOnAppear else { return }
            guard !didAutoJoin else { return }

            let trimmed = trimmedInput
            guard !trimmed.isEmpty else { return }

            didAutoJoin = true
            Task { await joinTapped() }
        }
        .toast($toast)
    }

    // MARK: - Actions

    private func pasteFromClipboardAndNormalize() {
        let pasted = UIPasteboard.general.string ?? ""
        input = pasted
        normalizeInput()

        if let token = viewModel.extractShareToken(from: pasted) {
            toast = Toast("Pegado ✅ (\(token))")
        } else {
            toast = Toast(pasted.isEmpty ? "Portapapeles vacío" : "Pegado ✅ (revisa el código)")
        }
        Haptics.light()
    }

    /// Convierte "https://loquesea/m/AB12" -> "AB12" y lo pone en mayúsculas.
    /// Usa tu lógica existente en MemorialListViewModel.
    private func normalizeInput() {
        let trimmed = trimmedInput

        if let token = viewModel.extractShareToken(from: trimmed) {
            input = token
        } else {
            input = trimmed
        }
    }

    @MainActor
    private func joinTapped() async {
        guard !isJoining else { return }

        errorMessage = nil
        normalizeInput()

        let trimmed = trimmedInput
        guard !trimmed.isEmpty else {
            errorMessage = "Pega un código o enlace para unirte."
            return
        }

        isJoining = true
        defer { isJoining = false }

        do {
            let memorial = try await viewModel.joinMemorial(using: trimmed)

            // ✅ Feedback agradable
            Haptics.success()

            // ✅ Dispara navegación automática en la lista
            viewModel.pendingNavigateToMemorial = memorial

            // ✅ Feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            // ✅ Cierra la vista
            dismiss()
        } catch let joinError as MemorialListViewModel.JoinMemorialError {
            // ✅ Mensaje inline más humano (y distinto según causa)
            switch joinError {
            case .invalidInput:
                errorMessage = "Ese código o enlace no parece válido. Pégalo completo y prueba otra vez."
                Haptics.light() // “ligera” (no es un fallo de red, solo input)
            case .notFound:
                errorMessage = "No he encontrado ningún memorial con ese código. Pide que te lo reenvíen."
                Haptics.error() // más “error” (es una negativa)
            }

        } catch {
            // Errores inesperados (red, permisos, etc.)
            errorMessage = "No he podido unirme ahora mismo. Inténtalo de nuevo en unos segundos."
            Haptics.error()
        }
    }
}
