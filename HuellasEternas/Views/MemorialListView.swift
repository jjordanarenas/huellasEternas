//
//  MemorialListView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//
import SwiftUI
import UIKit

struct MemorialListView: View {

    @EnvironmentObject var viewModel: MemorialListViewModel

    @State private var showingNewMemorialSheet = false

    // ✅ Navegación programática
    @State private var path = NavigationPath()

    // ✅ Join Sheet (con token opcional)
    @State private var showingJoinSheet = false
    @State private var joinPrefilledToken: String = ""

    // Toast
    @State private var toast: Toast? = nil

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Tus memoriales")

                // Destino del NavigationLink(value:)
                .navigationDestination(for: Memorial.self) { memorial in
                    MemorialDetailView(memorial: memorial)
                }

                // ✅ Toolbars recuperadas + botón de unirse abre SHEET
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 12) {
                            Button {
                                presentJoinFromClipboardIfPossible()
                            } label: {
                                Image(systemName: "person.crop.circle.badge.plus")
                            }
                            .accessibilityLabel("Unirme a un memorial")

                            NavigationLink {
                                ArchivedMemorialsView()
                                    .environmentObject(viewModel)
                            } label: {
                                Image(systemName: "archivebox")
                            }
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            // ✅ Ocultar EditButton si no hay suficiente para reorder
                            if viewModel.memorials.count > 1 {
                                EditButton()
                            }

                            Button {
                                showingNewMemorialSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }

                // ✅ Sheet: Nuevo memorial
                .sheet(isPresented: $showingNewMemorialSheet) {
                    NewMemorialView()
                        .environmentObject(viewModel)
                }

                // ✅ Sheet: Unirme (token opcional)
                .sheet(isPresented: $showingJoinSheet) {
                    NavigationStack {
                        JoinMemorialView(prefilledInput: joinPrefilledToken, autoJoinOnAppear: true)
                            .environmentObject(viewModel)
                    }
                }

                // ✅ Auto-navegación cuando el VM lo pide
                .onChange(of: viewModel.pendingNavigateToMemorial) { newValue in
                    guard let memorial = newValue else { return }
                    path.append(memorial)
                    viewModel.pendingNavigateToMemorial = nil
                }
                .toast($toast) // ✅ toast overlay
        }
    }

    // MARK: - Present Join helper

    /// Presenta la pantalla de "Unirme" con un token opcional.
    /// - Si `prefilled` no está vacío, JoinMemorialView hará auto-join al aparecer (por tu lógica actual).
    private func presentJoin(prefilled: String) {
        joinPrefilledToken = prefilled
        showingJoinSheet = true
    }

    // MARK: - Join helpers

    /// Abre la pantalla "Unirme".
    /// Si hay un código o enlace válido en el portapapeles,
    /// se pasa como prefilledInput y se hace auto-join.
    private func presentJoinFromClipboardIfPossible() {
        let clipboard = UIPasteboard.general.string ?? ""
        let trimmed = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)

        if let token = viewModel.extractShareToken(from: trimmed) {
            // 🎯 Caso pro: había token → auto-join
            joinPrefilledToken = token
        } else {
            // 🧼 Caso normal: no había nada útil
            joinPrefilledToken = ""
        }

        showingJoinSheet = true
    }

    // MARK: - Content (tu lógica de estados)

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
                        NavigationLink(value: memorial) {
                            MemorialRowView(memorial: memorial)
                        }
                        .swipeActions(edge: .trailing) {
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

    // MARK: - Join Flow
    private func openJoinFlowFromClipboardIfPossible() {
        let raw = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if let token = viewModel.extractShareToken(from: raw) {
            joinPrefilledToken = token
            showingJoinSheet = true
            toast = Toast("Código detectado y pegado ✅")
        } else {
            joinPrefilledToken = ""
            showingJoinSheet = true
            toast = Toast(raw.isEmpty ? "Pega un código o enlace para unirte" : "No detecté un código válido en el portapapeles")
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
