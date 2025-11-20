//
//  NewMemorialView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI

struct NewMemorialView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: MemorialListViewModel
    
    // Campos de formulario
    @State private var name: String = ""
    @State private var selectedPetType: PetType = .dog
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Mascota") {
                    TextField("Nombre de la mascota", text: $name)
                    
                    Picker("Tipo", selection: $selectedPetType) {
                        ForEach(PetType.allCases) { petType in
                            Text(petType.rawValue)
                                .tag(petType)
                        }
                    }
                }
            }
            .navigationTitle("Nuevo memorial")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        // Validación muy básica
                        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        viewModel.addMemorial(name: name, petType: selectedPetType)
                        dismiss()
                    }
                }
            }
        }
    }
}
