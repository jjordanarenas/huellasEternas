//
//  MemorialListView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI

struct MemorialListView: View {

    @EnvironmentObject var viewModel: MemorialListViewModel

    // Para abrir la sheet de “Nuevo memorial”
    @State private var showingNewMemorialSheet = false

    // NavigationPath para navegación programática (onboarding -> detalle)
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Tus memoriales")

                // ✅ Destino para NavigationLink(value:)
                .navigationDestination(for: Memorial.self) { memorial in
                    MemorialDetailView(memorial: memorial)
                }

                // ✅ Toolbar recuperada (unirse + crear)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink {
                            JoinMemorialView()
                                .environmentObject(viewModel)
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            EditButton()
                            NavigationLink {
                                ArchivedMemorialsView().environmentObject(viewModel)
                            } label: {
                                Image(systemName: "archivebox")
                            }
                            Button {
                                showingNewMemorialSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }

                // ✅ Sheet recuperada
                .sheet(isPresented: $showingNewMemorialSheet) {
                    NewMemorialView()
                        .environmentObject(viewModel)
                }

                // ✅ Navegación automática al memorial recién creado
                .onChange(of: viewModel.pendingNavigateToMemorial) { newValue in
                    guard let memorial = newValue else { return }
                    path.append(memorial)
                    viewModel.pendingNavigateToMemorial = nil
                }
        }
    }

    // MARK: - Content (estados)

    @ViewBuilder
    private var content: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Cargando tus memoriales…")
                    .padding()

            } else if let errorMessage = viewModel.loadErrorMessage {
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
                ContentUnavailableView(
                    "Aún no hay memoriales",
                    systemImage: "pawprint",
                    description: Text("Crea el primer memorial para recordar a tu compañero.")
                )

            } else {
                List {
                    ForEach(viewModel.memorials) { memorial in
                        // ✅ IMPORTANTE: usar NavigationLink(value:) para que funcione con navigationDestination(for:)
                        NavigationLink(value: memorial) {
                            // Si ya tenías MemorialRowView, úsalo:
                            MemorialRowView(memorial: memorial)

                            // Si no, usa esto:
                            // HStack(spacing: 12) {
                            //     Image(systemName: memorial.petType.systemImage)
                            //     Text(memorial.name)
                            // }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                Task { await viewModel.archive(memorial) }
                            } label: {
                                Label("Archivar", systemImage: "archivebox")
                            }
                        }
                    }
                    .onMove { indices, newOffset in
                        viewModel.moveMemorials(from: indices, to: newOffset)
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.loadMemorials()
                }
            }
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
