//
//  JournalView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI

/// Pantalla principal del Diario emocional.
/// Muestra la lista de entradas y permite crear nuevas.
struct JournalView: View {

    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntrySheet = false

    var body: some View {
        HuellasListContainer {
            Group {
                if viewModel.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.entries) { entry in
                            JournalEntryRow(entry: entry)
                                .listRowBackground(HuellasColor.card)
                        }
                        .onDelete(perform: viewModel.deleteEntries)
                    }
                    .listStyle(.insetGrouped)
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
                NewJournalEntryView { mood, text in
                    viewModel.addEntry(mood: mood, text: text)
                }
            }
        }
    }

    // ✅ Empty state propio (más control que ContentUnavailableView y 100% paleta)
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 38))
                .foregroundStyle(HuellasColor.primaryDark)

            Text("Tu diario está vacío")
                .font(.title3)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Escribe cómo te sientes hoy. Este espacio es solo para ti.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewEntrySheet = true
            } label: {
                Label("Escribir primera entrada", systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(HuellasColor.primary)
            .padding(.top, 4)
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
        .padding()
    }
}

/// Fila individual de una entrada del diario.
struct JournalEntryRow: View {

    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                Text(entry.mood.emoji)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.mood.rawValue)
                        .font(.headline)
                        .foregroundStyle(HuellasColor.textPrimary)

                    Text(formatDate(entry.createdAt))
                        .font(.caption)
                        .foregroundStyle(HuellasColor.textSecondary)
                }

                Spacer()
            }

            if !entry.text.isEmpty {
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
