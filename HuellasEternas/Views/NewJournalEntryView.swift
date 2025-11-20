//
//  NewJournalEntryView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//


import SwiftUI

/// Formulario para crear una nueva entrada del diario.
/// Devuelve los datos mediante un closure onSave.
struct NewJournalEntryView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // Estado de ánimo seleccionado
    @State private var selectedMood: JournalMood = .sad
    
    // Texto que escribe el usuario
    @State private var text: String = ""
    
    // Closure que la vista padre pasa para manejar el guardado
    let onSave: (JournalMood, String) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // Sección de estado de ánimo
                Section("¿Cómo te sientes hoy?") {
                    // Picker con los distintos estados
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
                
                // Sección de texto
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
                        // Podrías validar que haya texto, o permitir entradas solo de mood
                        onSave(selectedMood, text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
