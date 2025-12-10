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
struct NewJournalEntryView: View {

    @Environment(\.dismiss) private var dismiss

    // Estado de ánimo seleccionado
    @State private var selectedMood: JournalMood = .sad

    // Texto que escribe el usuario
    @State private var text: String = ""

    // Servicio que usaremos para generar mensajes de ánimo
    private let comfortService = ComfortMessageService()

    // Manager de suscripción (para saber si es Premium)
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // Manager del uso de IA gratuita
    private let aiUsageManager = AIUsageManager()

    // Estado de generación de mensaje de ánimo
    @State private var isGeneratingComfortMessage = false
    @State private var generationErrorMessage: String? = nil
    @State private var showGenerationErrorAlert = false

    // Control para mostrar el Paywall cuando se quede sin mensajes gratis
    @State private var showPaywall = false

    // Closure que la vista padre pasa para manejar el guardado
    let onSave: (JournalMood, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                // Sección de estado de ánimo
                Section("¿Cómo te sientes hoy?") {
                    Picker("Estado de ánimo", selection: $selectedMood) {
                        ForEach(JournalMood.allCases) { mood in
                            HStack {
                                Text(mood.emoji)
                                Text(mood.rawValue)
                            }
                            .tag(mood)
                        }
                    }
                }

                // Sección de texto + botón de IA
                Section("Cuéntame un poco más") {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $text)
                            .frame(minHeight: 150)
                            .padding(.top, 4)

                        if text.isEmpty {
                            Text("Escribe lo que sientas…")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }

                    // Info sobre mensajes gratis restantes (solo para no premium)
                    if !subscriptionManager.isPremium {
                        let remaining = aiUsageManager.remainingFreeMessages()
                        Text(remaining > 0
                             ? "Te quedan \(remaining) mensajes de ánimo gratis este mes."
                             : "Has usado todos tus mensajes de ánimo gratis este mes."
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    // Botón para generar mensaje de ánimo
                    Button {
                        Task {
                            await handleGenerateComfortMessageTapped()
                        }
                    } label: {
                        if isGeneratingComfortMessage {
                            HStack {
                                ProgressView()
                                Text("Buscando palabras de ánimo…")
                            }
                        } else {
                            Label("Necesito unas palabras de ánimo", systemImage: "sparkles")
                        }
                    }
                    .disabled(isGeneratingComfortMessage)
                }
            }
            .navigationTitle("Nueva entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancelar
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                // Guardar
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSave(selectedMood, text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            // Alert de error al generar mensaje de ánimo
            .alert("No se pudo generar el mensaje", isPresented: $showGenerationErrorAlert) {
                Button("Aceptar", role: .cancel) { }
            } message: {
                Text(generationErrorMessage ?? "Ha ocurrido un error inesperado.")
            }
            // 👇 Aquí mostramos el Paywall cuando no le quedan mensajes gratis
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    /// Se llama cuando el usuario pulsa el botón de "Necesito unas palabras de ánimo".
    @MainActor
    private func handleGenerateComfortMessageTapped() async {
        guard !isGeneratingComfortMessage else { return }

        // Si el usuario es Premium, IA ilimitada
        if subscriptionManager.isPremium {
            await generateComfortMessage()
            return
        }

        // Usuario no Premium: comprobar si le quedan mensajes gratis
        if aiUsageManager.canUseFreeMessage() {
            // Registramos el uso ANTES de llamar, para que si falla igual descuente
            aiUsageManager.registerMessageUsage()
            await generateComfortMessage()
        } else {
            // No le quedan mensajes gratis → mostramos Paywall
            showPaywall = true
        }
    }

    /// Llama al servicio de IA y actualiza el texto del editor.
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

            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
