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
            Group {
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
                            NavigationLink {
                                MemorialDetailView(memorial: memorial)
                            } label: {
                                MemorialRowView(memorial: memorial)
                            }
                            .listRowBackground(HuellasColor.card)
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
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Archivados")
            .toolbar {
                // (Opcional) icono back también en dorado
                ToolbarItem(placement: .topBarTrailing) {
                    EmptyView()
                }
            }
            .refreshable {
                await viewModel.loadMemorials()
            }
        }
    }
}
