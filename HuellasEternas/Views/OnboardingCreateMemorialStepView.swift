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

    private var trimmedName: String {
        petName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HuellasListContainer {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Crea el primer memorial")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(HuellasColor.textPrimary)

                        Text("Un primer paso sencillo. Después podrás seguir completándolo cuando te apetezca.")
                            .font(.subheadline)
                            .foregroundStyle(HuellasColor.textSecondary)
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(HuellasColor.card)

                Section("Tu mascota") {
                    TextField("Nombre", text: $petName)
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(HuellasColor.textPrimary)

                    Picker("Tipo", selection: $petType) {
                        ForEach(PetType.allCases) { type in
                            Label(type.rawValue, systemImage: type.systemImage)
                                .tag(type)
                        }
                    }
                    .tint(HuellasColor.primaryDark)
                }
                .listRowBackground(HuellasColor.card)

                Section("Frase corta (opcional)") {
                    TextField("Ej: “Siempre contigo”", text: $shortQuote)
                        .foregroundStyle(HuellasColor.textPrimary)

                    Text("Puedes dejarlo en blanco si hoy no te sale.")
                        .font(.footnote)
                        .foregroundStyle(HuellasColor.textSecondary)
                }
                .listRowBackground(HuellasColor.card)

                if let errorMessage {
                    Section {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)

                            Text(errorMessage)
                                .foregroundStyle(HuellasColor.textPrimary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(HuellasColor.card)
                }

                Section {
                    Button {
                        onCreate()
                    } label: {
                        HStack(spacing: 10) {
                            if isCreating {
                                ProgressView()
                                    .tint(HuellasColor.textPrimary)
                                Text("Creando memorial…")
                                    .foregroundStyle(HuellasColor.textPrimary)
                            } else {
                                Text("Crear memorial")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(HuellasColor.primary)
                    .disabled(isCreating || trimmedName.isEmpty)

                    if trimmedName.isEmpty {
                        Text("Escribe el nombre para continuar.")
                            .font(.caption)
                            .foregroundStyle(HuellasColor.textSecondary)
                            .padding(.top, 4)
                    }
                }
                .listRowBackground(HuellasColor.card)
            }
            .scrollContentBackground(.hidden)
        }
    }
}
