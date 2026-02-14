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

    @State private var name: String = ""
    @State private var selectedPetType: PetType = .dog

    @FocusState private var isNameFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty
    }

    var body: some View {
        NavigationStack {
            HuellasScreen {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        header

                        petCard

                        tipCard

                        Spacer(minLength: 20)
                    }
                    .padding()
                }
                .navigationTitle("Nuevo memorial")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        isNameFocused = true
                    }
                }
            }
        }
    }

    // MARK: - UI

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Crear un memorial")
                .font(.title3)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Un espacio bonito y sencillo para recordar a tu compañero.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
    }

    private var petCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Mascota", systemImage: "pawprint.fill")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Nombre")
                    .font(.caption)
                    .foregroundStyle(HuellasColor.textSecondary)

                TextField("Ej: Luna", text: $name)
                    .focused($isNameFocused)
                    .foregroundStyle(HuellasColor.textPrimary)
                    .submitLabel(.done)
                    .padding(12)
                    .background(HuellasColor.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(HuellasColor.divider, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tipo")
                    .font(.caption)
                    .foregroundStyle(HuellasColor.textSecondary)

                Picker("Tipo", selection: $selectedPetType) {
                    ForEach(PetType.allCases) { petType in
                        Label(petType.rawValue, systemImage: petType.systemImage)
                            .tag(petType)
                    }
                }
                .tint(HuellasColor.primaryDark)
                .padding(12)
                .background(HuellasColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HuellasColor.divider, lineWidth: 1)
                )
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

    private var tipCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "heart.text.square")
                .foregroundStyle(HuellasColor.primaryDark)

            Text("Tip: un memorial sencillo es suficiente. Más adelante podrás añadir recuerdos, fotos y anécdotas con calma.")
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

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") { dismiss() }
                .foregroundStyle(HuellasColor.primaryDark)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Guardar") {
                guard canSave else { return }
                viewModel.addMemorial(name: trimmedName, petType: selectedPetType)
                Haptics.success()
                dismiss()
            }
            .foregroundStyle(HuellasColor.primaryDark)
            .disabled(!canSave)
        }
    }
}
