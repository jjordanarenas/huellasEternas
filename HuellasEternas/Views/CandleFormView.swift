//
//  CandleFormView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 19/11/25.
//


import SwiftUI

/// Vista que muestra un pequeño formulario antes de encender una vela.
/// Permite introducir nombre y mensaje opcionales.
struct CandleFormView: View {
    
    // Para poder cerrar el sheet desde dentro
    @Environment(\.dismiss) private var dismiss
    
    // Campos del formulario
    @State private var name: String = ""
    @State private var message: String = ""
    
    // Closure que la vista padre nos pasa para ejecutar la acción
    // cuando el usuario pulsa "Encender vela".
    // Le devolvemos opcionalmente el nombre y el mensaje.
    let onConfirm: (String?, String?) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("¿Quién enciende la vela?") {
                    TextField("Tu nombre (opcional)", text: $name)
                }
                
                Section("Mensaje para \(/* podemos personalizar fuera si quieres */"la mascota")") {
                    // TextEditor es mejor que TextField para mensajes largos
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .overlay(
                            // Placeholder casero cuando el mensaje está vacío
                            Group {
                                if message.isEmpty {
                                    Text("Escribe un mensaje (opcional)...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                }
            }
            .navigationTitle("Encender una vela")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón cancelar
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                // Botón confirmar
                ToolbarItem(placement: .confirmationAction) {
                    Button("Encender") {
                        // Llamamos al closure pasando los valores actuales
                        onConfirm(name, message)
                        // Cerramos el sheet
                        dismiss()
                    }
                }
            }
        }
    }
}
