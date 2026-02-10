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
        HuellasListContainer {
            content
                .navigationTitle("Archivados")
                .navigationDestination(for: Memorial.self) { memorial in
                    MemorialDetailView(memorial: memorial)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.archivedMemorials.isEmpty {
            ContentUnavailableView(
                "No tienes memoriales archivados",
                systemImage: "archivebox",
                description: Text("Cuando archives uno, aparecerá aquí para que puedas restaurarlo cuando quieras.")
            )
            .foregroundStyle(HuellasColor.textPrimary)

        } else {
            List {
                ForEach(viewModel.archivedMemorials) { memorial in
                    NavigationLink(value: memorial) {
                        MemorialRowView(memorial: memorial)
                    }
                    .huellasRowCard()
                    .swipeActions(edge: .trailing) {
                        Button {
                            Task { await viewModel.restore(memorial) }
                        } label: {
                            Label("Restaurar", systemImage: "arrow.uturn.backward")
                        }
                        .tint(HuellasColor.primaryDark)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await viewModel.loadMemorials() }
        }
    }
}
