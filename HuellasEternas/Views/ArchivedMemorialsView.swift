//
//  ArchivedMemorialsView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 17/12/25.
//


import SwiftUI

struct ArchivedMemorialsView: View {
    @EnvironmentObject var viewModel: MemorialListViewModel

    var body: some View {
        List {
            ForEach(viewModel.archivedMemorials) { memorial in
                NavigationLink(value: memorial) {
                    MemorialRowView(memorial: memorial)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        Task { await viewModel.restore(memorial) }
                    } label: {
                        Label("Restaurar", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.blue)
                }
            }
        }
        .navigationTitle("Archivados")
        .navigationDestination(for: Memorial.self) { memorial in
            MemorialDetailView(memorial: memorial)
        }
        .refreshable {
            await viewModel.loadMemorials()
        }
    }
}
