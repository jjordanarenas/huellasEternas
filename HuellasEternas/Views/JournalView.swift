//
//  JournalView 2.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//


import SwiftUI

/// Pantalla principal del Diario emocional.
/// Muestra la lista de entradas y permite crear nuevas.
struct JournalView: View {
    
    // Usamos @StateObject porque este ViewModel vive ligado a esta vista.
    // Si prefieres, se puede mover al nivel App y usar @EnvironmentObject.
    @StateObject private var viewModel = JournalViewModel()
    
    // Controla si mostramos el sheet para nueva entrada
    @State private var showingNewEntrySheet = false
    
    var body: some View {
        VStack {
            if viewModel.entries.isEmpty {
                // Estado vacío (sin entradas todavía)
                ContentUnavailableView(
                    "Tu diario está vacío",
                    systemImage: "book.closed",
                    description: Text("Escribe cómo te sientes hoy. Este espacio es solo para ti.")
                )
            } else {
                // Lista de entradas
                List {
                    ForEach(viewModel.entries) { entry in
                        JournalEntryRow(entry: entry)
                    }
                    .onDelete(perform: viewModel.deleteEntries) // swipe para borrar
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Diario")
        .toolbar {
            // Botón para crear nueva entrada
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewEntrySheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        // Presenta el formulario de nueva entrada como sheet
        .sheet(isPresented: $showingNewEntrySheet) {
            NewJournalEntryView { mood, text in
                viewModel.addEntry(mood: mood, text: text)
            }
        }
    }
}

/// Fila individual de una entrada del diario.
struct JournalEntryRow: View {
    
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.mood.emoji)
                    .font(.title2)
                
                Text(entry.mood.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text(formatDate(entry.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !entry.text.isEmpty {
                Text(entry.text)
                    .font(.body)
                    .lineLimit(3) // mostramos solo las primeras líneas
            }
        }
        .padding(.vertical, 4)
    }
    
    /// Fecha relativa tipo "hace 2 h" o fecha corta.
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
