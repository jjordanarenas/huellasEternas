//
//  JoinMemorialView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/12/25.
//


import SwiftUI

/// Pantalla para unirse a un memorial usando un código o un enlace compartido.
struct JoinMemorialView: View {
    
    @EnvironmentObject var listViewModel: MemorialListViewModel
    
    // Texto que pega el usuario (código o URL)
    @State private var inputText: String = ""
    
    // Estado de búsqueda
    @State private var isSearching: Bool = false
    @State private var errorMessage: String? = nil
    
    // Memorial encontrado (si lo hay)
    @State private var foundMemorial: Memorial? = nil
    
    var body: some View {
        Form {
            Section("Pega el código o enlace") {
                TextField("Ej: AB12CD34 o https://huellas.app/m/AB12CD34", text: $inputText)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
            }
            
            Section {
                Button {
                    Task { await searchMemorial() }
                } label: {
                    if isSearching {
                        HStack {
                            ProgressView()
                            Text("Buscando memorial…")
                        }
                    } else {
                        Label("Buscar memorial", systemImage: "magnifyingglass")
                    }
                }
                .disabled(isSearching || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
            }
            
            if let memorial = foundMemorial {
                Section("Memorial encontrado") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(memorial.name)
                            .font(.headline)
                        Text(memorial.petType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let quote = memorial.shortQuote, !quote.isEmpty {
                            Text("“\(quote)”")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        NavigationLink {
                            MemorialDetailView(memorial: memorial)
                        } label: {
                            Label("Ir al memorial", systemImage: "pawprint.fill")
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Unirme a un memorial")
    }
    
    @MainActor
    private func searchMemorial() async {
        guard !isSearching else { return }
        isSearching = true
        errorMessage = nil
        foundMemorial = nil
        
        do {
            let memorial = try await listViewModel.joinMemorial(using: inputText)
            foundMemorial = memorial
        } catch {
            AnalyticsManager.shared.log(AEvent.joinMemorial, [
                "result": "not_found"
            ])
            if let joinError = error as? MemorialListViewModel.JoinMemorialError {
                errorMessage = joinError.errorDescription
            } else {
                errorMessage = "Ha ocurrido un error al buscar el memorial."
            }
        }
        
        isSearching = false
    }
}
