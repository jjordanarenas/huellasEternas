//
//  JournalView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI

/// Pantalla principal del Diario emocional.
/// Muestra la lista de entradas y permite crear nuevas.
import SwiftUI

struct JournalView: View {

    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntrySheet = false

    var body: some View {
        HuellasListContainer {
            Group {
                if viewModel.entries.isEmpty {
                    ContentUnavailableView(
                        "Tu diario está vacío",
                        systemImage: "book.closed",
                        description: Text("Escribe cómo te sientes hoy. Este espacio es solo para ti.")
                    )
                    .foregroundStyle(HuellasColor.textPrimary)
                    .symbolRenderingMode(.hierarchical)
                    .tint(HuellasColor.primaryDark) // icono
                } else {
                    List {
                        ForEach(viewModel.entries) { entry in
                            JournalEntryRow(entry: entry)
                                .listRowBackground(HuellasColor.card)
                        }
                        .onDelete(perform: viewModel.deleteEntries)
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden) // ✅ evita fondo blanco del List
                }
            }
            .navigationTitle("Diario")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewEntrySheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(HuellasColor.primaryDark)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntrySheet) {
                NavigationStack {
                    NewJournalEntryView { mood, text in
                        viewModel.addEntry(mood: mood, text: text)
                    }
                }
                .tint(HuellasColor.primaryDark)
            }
        }
    }
}

/// Fila individual de una entrada del diario.
struct JournalEntryRow: View {

    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack(alignment: .firstTextBaseline) {
                Text(entry.mood.emoji)
                    .font(.title2)

                Text(entry.mood.rawValue)
                    .font(.headline)
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()

                Text(formatDate(entry.createdAt))
                    .font(.caption)
                    .foregroundStyle(HuellasColor.textSecondary)
            }

            if !entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(entry.text)
                    .font(.body)
                    .foregroundStyle(HuellasColor.textPrimary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 6)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
