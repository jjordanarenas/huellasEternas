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

    @State private var didAutoJoin: Bool = false
    @State private var toast: Toast? = nil

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
        HuellasScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    header

                    codeCard

                    if let errorMessage {
                        errorCard(errorMessage)
                    }

                    joinButton

                    tipCard

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Unirme")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                guard shouldAutoJoinOnAppear,
                      !didAutoJoin,
                      !trimmedInput.isEmpty else { return }

                didAutoJoin = true
                Task { await joinTapped() }
            }
            .toast($toast)
        }
    }

    // MARK: - UI

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Unirte a un memorial")
                .font(.title3)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Introduce el código que te han compartido para unirte.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
    }

    private var codeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Código o enlace", systemImage: "key.fill")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            TextField("Pega aquí el código o enlace", text: $input)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .foregroundStyle(HuellasColor.textPrimary)
                .padding(12)
                .background(HuellasColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HuellasColor.divider, lineWidth: 1)
                )
                .onSubmit { Task { await joinTapped() } }

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
                    Haptics.light()
                } label: {
                    Label("Normalizar", systemImage: "wand.and.stars")
                }
                .foregroundStyle(HuellasColor.textSecondary)
                .disabled(trimmedInput.isEmpty || isJoining)
            }
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }

    private func errorCard(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(HuellasColor.primaryDark)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textPrimary)
        }
        .padding()
        .background(HuellasColor.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }

    private var joinButton: some View {
        Button {
            Task { await joinTapped() }
        } label: {
            HStack(spacing: 10) {
                if isJoining {
                    ProgressView()
                        .tint(HuellasColor.textPrimary)
                }
                Text(isJoining ? "Uniéndome…" : "Unirme")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(HuellasColor.primary)
        .disabled(!canJoin)
    }

    private var tipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundStyle(HuellasColor.textSecondary)

            Text("Si te han enviado un enlace, puedes pegarlo aquí. La app extraerá el código automáticamente.")
                .font(.footnote)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }

    // MARK: - Logic

    private func pasteFromClipboardAndNormalize() {
        let pasted = UIPasteboard.general.string ?? ""
        input = pasted
        normalizeInput()

        if let token = viewModel.extractShareToken(from: pasted) {
            toast = Toast("Código detectado y pegado ✅")
        } else {
            toast = Toast(pasted.isEmpty ? "Portapapeles vacío" : "Pegado, revisa el código")
        }
        Haptics.light()
    }

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

            Haptics.success()
            viewModel.pendingNavigateToMemorial = memorial
            dismiss()

        } catch let joinError as MemorialListViewModel.JoinMemorialError {
            switch joinError {
            case .invalidInput:
                errorMessage = "Ese código o enlace no parece válido."
                Haptics.light()
            case .notFound:
                errorMessage = "No se ha encontrado ningún memorial con ese código."
                Haptics.error()
            }
        } catch {
            errorMessage = "No he podido unirme ahora mismo. Inténtalo de nuevo en unos segundos."
            Haptics.error()
        }
    }
}
