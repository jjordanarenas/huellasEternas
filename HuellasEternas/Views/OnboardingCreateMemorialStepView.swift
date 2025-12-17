//
//  OnboardingCreateMemorialStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import SwiftUI

struct OnboardingCreateMemorialStepView: View {
    
    @Binding var petName: String
    @Binding var petType: PetType
    @Binding var shortQuote: String
    
    let errorMessage: String?
    let isCreating: Bool
    let onCreate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Crea el primer memorial")
                .font(.title2)
                .bold()
                .padding(.top, 8)
            
            Form {
                Section("Tu mascota") {
                    TextField("Nombre", text: $petName)
                        .textInputAutocapitalization(.words)
                    
                    Section("Tipo de mascota") {
                        PetTypeSelectorView(selectedType: $petType)
                    }
                }
                
                Section("Frase corta (opcional)") {
                    TextField("Ej: “Siempre contigo”", text: $shortQuote)
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button {
                        onCreate()
                    } label: {
                        if isCreating {
                            HStack {
                                ProgressView()
                                Text("Creando memorial…")
                            }
                        } else {
                            Text("Crear memorial")
                        }
                    }
                    .disabled(isCreating)
                }
            }
        }
    }
}
