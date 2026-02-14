//
//  NewJournalEntryView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI

/// Formulario para crear una nueva entrada del diario.
/// Incluye un botón "Necesito unas palabras de ánimo"
/// que usa IA con límite mensual para usuarios no Premium.
import SwiftUI

struct NewJournalEntryView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selectedMood: JournalMood = .sad
    @State private var text: String = ""

    private let comfortService = ComfortMessageService()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    private let aiUsageManager = AIUsageManager()

    @State private var isGeneratingComfortMessage = false
    @State private var generationErrorMessage: String? = nil
    @State private var showGenerationErrorAlert = false
    @State private var showPaywall = false

    let onSave: (JournalMood, String) -> Void

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HuellasListContainer(topInset: 0) { // ✅ para Form, mejor 0
            Form {

                Section("¿Cómo te sientes hoy?") {
                    Picker("Estado de ánimo", selection: $selectedMood) {
                        ForEach(JournalMood.allCases) { mood in
                            HStack {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                                    .foregroundStyle(HuellasColor.textPrimary)
                            }
                            .tag(mood)
                        }
                    }
                    .tint(HuellasColor.primaryDark)
                }
                .listRowBackground(HuellasColor.card)

                Section("Cuéntame un poco más") {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .frame(minHeight: 160)
                            .foregroundStyle(HuellasColor.textPrimary)
                            .scrollContentBackground(.hidden)
                            .background(HuellasColor.backgroundSecondary) // ✅ evita “blanco”
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(HuellasColor.divider, lineWidth: 1)
                            )

                        if text.isEmpty {
                            Text("Escribe lo que sientas…")
                                .foregroundStyle(HuellasColor.textSecondary)
                                .padding(.top, 12)
                                .padding(.leading, 12)
                        }
                    }
                    .padding(.vertical, 4)

                    if !subscriptionManager.isPremium {
                        let remaining = aiUsageManager.remainingFreeMessages()

                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: remaining > 0 ? "gift.fill" : "lock.fill")
                                .foregroundStyle(HuellasColor.primaryDark)

                            Text(
                                remaining > 0
                                ? "Te quedan \(remaining) mensajes de ánimo gratis este mes."
                                : "Has usado todos tus mensajes de ánimo gratis este mes."
                            )
                            .font(.caption)
                            .foregroundStyle(HuellasColor.textSecondary)

                            Spacer()
                        }
                        .padding(.top, 2)
                    }

                    Button {
                        Task { await handleGenerateComfortMessageTapped() }
                    } label: {
                        if isGeneratingComfortMessage {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .tint(HuellasColor.textPrimary)
                                Text("Buscando palabras de ánimo…")
                                    .foregroundStyle(HuellasColor.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Label("Necesito unas palabras de ánimo", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isGeneratingComfortMessage)
                    .buttonStyle(.borderedProminent)
                    .tint(HuellasColor.primary) // ✅ CTA dorado
                    .padding(.top, 6)
                }
                .listRowBackground(HuellasColor.card)
            }
            .scrollContentBackground(.hidden) // ✅ fondo general del Form
            .navigationTitle("Nueva entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(HuellasColor.primaryDark)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onSave(selectedMood, text)
                        dismiss()
                    }
                    .foregroundStyle(HuellasColor.primaryDark)
                    .disabled(trimmedText.isEmpty)
                }
            }
            .alert("No se pudo generar el mensaje", isPresented: $showGenerationErrorAlert) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text(generationErrorMessage ?? "Ha ocurrido un error inesperado.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - IA

    @MainActor
    private func handleGenerateComfortMessageTapped() async {
        guard !isGeneratingComfortMessage else { return }

        if subscriptionManager.isPremium {
            await generateComfortMessage()
            return
        }

        if aiUsageManager.canUseFreeMessage() {
            aiUsageManager.registerMessageUsage()
            await generateComfortMessage()
        } else {
            AnalyticsManager.shared.log(AEvent.paywallOpened, [
                "source": "ai_limit"
            ])
            showPaywall = true
        }
    }

    @MainActor
    private func generateComfortMessage() async {
        guard !isGeneratingComfortMessage else { return }

        isGeneratingComfortMessage = true
        generationErrorMessage = nil

        do {
            let message = try await comfortService.generateComfortMessage(
                mood: selectedMood,
                currentText: text
            )

            AnalyticsManager.shared.log(AEvent.aiGenerated, [
                "mood": selectedMood.rawValue,
                "is_premium": SubscriptionManager.shared.isPremium ? "1" : "0"
            ])

            if trimmedText.isEmpty {
                text = message
            } else {
                text += "\n\n" + message
            }
        } catch {
            print("❌ Error generando mensaje de ánimo: \(error)")
            generationErrorMessage = "No se han podido generar palabras de ánimo. Inténtalo de nuevo en un momento."
            showGenerationErrorAlert = true
        }

        isGeneratingComfortMessage = false
    }
}
