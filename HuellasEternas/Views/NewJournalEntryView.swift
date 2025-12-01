//
//  NewJournalEntryView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI

/// Formulario para crear una nueva entrada del diario.
/// Ahora incluye un botón "Necesito unas palabras de ánimo"
/// que genera un texto corto usando ComfortMessageService.
struct NewJournalEntryView: View {

    @Environment(\.dismiss) private var dismiss

    // Estado de ánimo seleccionado
    @State private var selectedMood: JournalMood = .sad

    // Texto que escribe el usuario
    @State private var text: String = ""

    // Servicio que usaremos para generar mensajes de ánimo
    private let comfortService = ComfortMessageService()

    // Estado de generación de mensaje de ánimo
    @State private var isGeneratingComfortMessage = false
    @State private var generationErrorMessage: String? = nil
    @State private var showGenerationErrorAlert = false

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

                    // Botón para generar mensaje de ánimo
                    Button {
                        Task {
                            await generateComfortMessage()
                        }
                    } label: {
                        // Mostramos spinner si está generando
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
        }
    }

    /// Llama al servicio de mensajes de ánimo y actualiza el texto del editor.
    @MainActor
    private func generateComfortMessage() async {
        guard !isGeneratingComfortMessage else { return }

        isGeneratingComfortMessage = true
        generationErrorMessage = nil

        do {
            // Llamamos al servicio con el mood actual y el texto que ya tenga el usuario
            let message = try await comfortService.generateComfortMessage(
                mood: selectedMood,
                currentText: text
            )

            // Integramos el mensaje en el TextEditor:
            // - Si está vacío, lo ponemos directamente
            // - Si ya hay algo, lo añadimos debajo con un salto de línea
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
