//
//  MemorialListView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI

struct MemorialListView: View {

    @EnvironmentObject var viewModel: MemorialListViewModel
    @State private var showingNewMemorialSheet = false

    var body: some View {
        VStack {
            if viewModel.isLoading {
                // Estado de carga
                ProgressView("Cargando tus memoriales…")
                    .padding()
            } else if let errorMessage = viewModel.loadErrorMessage {
                // Estado de error
                VStack(spacing: 12) {
                    Text("Ha ocurrido un problema")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button {
                        Task { await viewModel.loadMemorials() }
                    } label: {
                        Label("Reintentar", systemImage: "arrow.clockwise")
                    }
                }
                .padding()
            } else if viewModel.memorials.isEmpty {
                // Sin memoriales todavía
                ContentUnavailableView(
                    "Aún no hay memoriales",
                    systemImage: "pawprint",
                    description: Text("Crea el primer memorial para recordar a tu compañero.")
                )
            } else {
                // Lista de memoriales
                List(viewModel.memorials) { memorial in
                    NavigationLink {
                        MemorialDetailView(memorial: memorial)
                    } label: {
                        MemorialRowView(memorial: memorial)
                    }
                }
                .listStyle(.insetGrouped)
                // Permite "arrastrar para refrescar" la lista
                .refreshable {
                    await viewModel.loadMemorials()
                }
            }
        }
        .navigationTitle("Tus memoriales")
        .toolbar {
            // Botón "Unirme" a la izquierda (por ejemplo)
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    JoinMemorialView()
                        .environmentObject(viewModel)
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewMemorialSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingNewMemorialSheet) {
            NewMemorialView()
                .environmentObject(viewModel)
        }
    }
}

// Vista de una fila individual en la lista de memoriales
struct MemorialRowView: View {
    
    let memorial: Memorial
    
    var body: some View {
        HStack {
            // En el futuro podríamos poner aquí la foto circular de la mascota
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                Image(systemName: "pawprint.fill")
            }
            .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(memorial.name)
                    .font(.headline)
                
                Text(memorial.petType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let quote = memorial.shortQuote {
                    Text(quote)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
