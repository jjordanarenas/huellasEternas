import SwiftUI
import UIKit

struct MemorialListView: View {

    @EnvironmentObject var viewModel: MemorialListViewModel

    //@Binding var path: NavigationPath
    @State private var showingNewMemorialSheet = false
    @State private var path = NavigationPath()

    @State private var showingJoinSheet = false
    @State private var joinPrefilledToken: String = ""

    @State private var toast: Toast? = nil

    var body: some View {
        NavigationStack(path: $path) {
            HuellasListContainer {
                content
                    .navigationTitle("Tus memoriales")

                    .navigationDestination(for: Memorial.self) { memorial in
                        MemorialDetailView(memorial: memorial)
                    }

                    .toolbar { toolbarContent }

                    .sheet(isPresented: $showingNewMemorialSheet) {
                        NewMemorialView()
                            .environmentObject(viewModel)
                    }

                    .sheet(isPresented: $showingJoinSheet) {
                        NavigationStack {
                            JoinMemorialView(prefilledInput: joinPrefilledToken, autoJoinOnAppear: true)
                                .environmentObject(viewModel)
                        }
                        .tint(HuellasColor.primaryDark)
                    }

                    .onChange(of: viewModel.pendingNavigateToMemorial) { newValue in
                        guard let memorial = newValue else { return }
                        path.append(memorial)
                        viewModel.pendingNavigateToMemorial = nil
                    }

                    .toast($toast)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 12) {
                Button {
                    presentJoinFromClipboardIfPossible()
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundStyle(HuellasColor.primaryDark)
                }
                .accessibilityLabel("Unirme a un memorial")

                NavigationLink {
                    ArchivedMemorialsView()
                        .environmentObject(viewModel)
                } label: {
                    Image(systemName: "archivebox")
                        .foregroundStyle(HuellasColor.primaryDark)
                }
                .accessibilityLabel("Archivados")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                if viewModel.memorials.count > 1 {
                    EditButton()
                        .foregroundStyle(HuellasColor.primaryDark)
                }

                Button {
                    showingNewMemorialSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(HuellasColor.primaryDark)
                }
                .accessibilityLabel("Nuevo memorial")
            }
        }
    }

    // MARK: - Join helpers

    private func presentJoinFromClipboardIfPossible() {
        let clipboard = UIPasteboard.general.string ?? ""
        let trimmed = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)

        if let token = viewModel.extractShareToken(from: trimmed) {
            joinPrefilledToken = token
        } else {
            joinPrefilledToken = ""
        }

        showingJoinSheet = true
    }

    // MARK: - Content (estados)

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingState

        } else if let errorMessage = viewModel.loadErrorMessage {
            errorState(errorMessage)

        } else if viewModel.memorials.isEmpty {
            emptyState

        } else {
            /*VStack(spacing: 0) {
                Color.clear
                    .frame(height: 10)   // ✅ tu “10px”
                    .accessibilityHidden(true)*/
                memorialsList
            //}
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.15)
                .tint(HuellasColor.primaryDark)

            Text("Cargando tus memoriales…")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Text("Ha ocurrido un problema")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)

            Button {
                Task { await viewModel.loadMemorials() }
            } label: {
                Label("Reintentar", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .tint(HuellasColor.primaryDark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Aún no hay memoriales",
            systemImage: "pawprint",
            description: Text("Crea el primer memorial para recordar a tu compañero.")
        )
        .foregroundStyle(HuellasColor.textPrimary)
    }
/*
    private var emptyFrame: some View {
        VStack(spacing: 100) {
            Text("")
        }
    }
*/
    private var memorialsList: some View {

        List {
            ForEach(viewModel.memorials) { memorial in
                NavigationLink(value: memorial) {
                    MemorialRowView(memorial: memorial)
                }
                .huellasRowCard()
                .swipeActions(edge: .trailing) {
                    Button {
                        Task { await viewModel.archive(memorial) }
                    } label: {
                        Label("Archivar", systemImage: "archivebox")
                    }
                    .tint(HuellasColor.primaryDark) // ✅ coherente con paleta
                }
            }
            .onMove { indices, newOffset in
                viewModel.moveMemorials(from: indices, to: newOffset)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.loadMemorials() }
        .scrollContentBackground(.hidden)
        .background(HuellasColor.background)
    }
}

// MARK: - Row

struct MemorialRowView: View {

    let memorial: Memorial

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(HuellasColor.backgroundSecondary)

                Circle()
                    .stroke(HuellasColor.divider, lineWidth: 1)

                Image(systemName: memorial.petType.systemImage)
                    .foregroundStyle(HuellasColor.primaryDark)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(memorial.name)
                    .font(.headline)
                    .foregroundStyle(HuellasColor.textPrimary)

                Text(memorial.petType.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)

                if let quote = memorial.shortQuote,
                   !quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(quote)
                        .font(.footnote)
                        .foregroundStyle(HuellasColor.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}
