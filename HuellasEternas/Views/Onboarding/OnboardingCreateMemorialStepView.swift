//
//  OnboardingCreateMemorialStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//
/*
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
        .background(HuellasColor.background)   // ✅ aquí el fondo
        .tint(HuellasColor.primaryDark)
    }


    // MARK: - Sections

    private var headerSection: some View {
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
    }

    private var petSection: some View {
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
    }

    private var quoteSection: some View {
        Section("Frase corta (opcional)") {
            TextField("Ej: “Siempre contigo”", text: $shortQuote)
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Puedes dejarlo en blanco si hoy no te sale.")
                .font(.footnote)
                .foregroundStyle(HuellasColor.textSecondary)
        }
    }

    private func errorSection(_ message: String) -> some View {
        Section {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)

                Text(message)
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .padding(.vertical, 4)
        }
    }

    private var actionSection: some View {
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
                .padding(.vertical, 2) // ✅ evita “bailes” entre estados
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
    }
}
*/

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
        // OJO: aquí NO uses Form. Es ScrollView + cards.
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {

                headerCard

                petCard

                quoteCard

                if let errorMessage {
                    errorCard(errorMessage)
                }

                createButtonCard
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(HuellasColor.background)
    }

    // MARK: - Cards

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Crea el primer memorial")
                .font(.title2)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Un primer paso sencillo. Después podrás seguir completándolo cuando te apetezca.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .cardStyle()
    }

    private var petCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Tu mascota")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)

                TextField("Ej: Luna", text: $petName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .foregroundStyle(HuellasColor.textPrimary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(HuellasColor.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(HuellasColor.divider, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tipo")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)

                PetTypeSelectorView(selectedType: $petType)
            }
        }
        .cardStyle()
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Frase corta (opcional)")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            TextField("Ej: “Siempre contigo”", text: $shortQuote)
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(HuellasColor.textPrimary)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(HuellasColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HuellasColor.divider, lineWidth: 1)
                )

            Text("Puedes dejarlo en blanco si hoy no te sale.")
                .font(.footnote)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .cardStyle()
    }

    private func errorCard(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)

            Text(message)
                .foregroundStyle(HuellasColor.textPrimary)
        }
        .cardStyle()
    }

    private var createButtonCard: some View {
        VStack(alignment: .leading, spacing: 10) {
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
            }
        }
        .cardStyle()
    }
}
