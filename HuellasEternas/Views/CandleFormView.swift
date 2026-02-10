import SwiftUI

struct CandleFormView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var message: String = ""

    let onConfirm: (String?, String?) -> Void

    var body: some View {
        NavigationStack {
            HuellasListContainer(topInset: 0) {
                Form {
                    Section("¿Quién enciende la vela?") {
                        TextField("Tu nombre (opcional)", text: $name)
                            .foregroundStyle(HuellasColor.textPrimary)
                    }
                    .listRowBackground(HuellasColor.card)

                    Section("Mensaje") {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $message)
                                .frame(minHeight: 120)
                                .foregroundStyle(HuellasColor.textPrimary)
                                .scrollContentBackground(.hidden)

                            if message.isEmpty {
                                Text("Escribe un mensaje (opcional)...")
                                    .foregroundStyle(HuellasColor.textSecondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .listRowBackground(HuellasColor.card)
                }
                .scrollContentBackground(.hidden)              // ✅ evita blanco del Form
                .background(HuellasColor.background)           // ✅ refuerzo
                .navigationTitle("Encender una vela")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarContent }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") { dismiss() }
                .foregroundStyle(HuellasColor.primaryDark)
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Encender") {
                onConfirm(name, message)
                dismiss()
            }
            .foregroundStyle(HuellasColor.primaryDark)
            .tint(HuellasColor.primary) // ✅ si quieres el botón “gold” (opcional)
        }
    }
}
