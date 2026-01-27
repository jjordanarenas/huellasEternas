//
//  RoutinesView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI

struct RoutinesView: View {

    // Rutinas locales
    private let routines = RoutineCatalog.all
    private let progressStore = RoutineProgressStore()

    var body: some View {
        List {
            Section {
                Text("Rutinas cortas para acompañarte en días difíciles. No tienes que hacerlas perfectas; solo empezar.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
            }

            Section("Rutinas") {
                ForEach(routines) { routine in
                    NavigationLink {
                        RoutineDetailView(routine: routine, progressStore: progressStore)
                    } label: {
                        RoutineRowView(routine: routine,
                                       count: progressStore.completionCount(for: routine.id),
                                       lastDate: progressStore.lastCompletedAt(for: routine.id))
                    }
                }
            }
        }
        .navigationTitle("Rutinas")
        .listStyle(.insetGrouped)
    }
}

private struct RoutineRowView: View {
    let routine: Routine
    let count: Int
    let lastDate: Date?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: routine.iconSystemName)
                .font(.system(size: 22))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(routine.title).font(.headline)
                    Spacer()
                    Text("~\(routine.estimatedMinutes) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(routine.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Estado de progreso (simple)
                HStack(spacing: 10) {
                    if count > 0 {
                        Text("Hecha \(count)x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    if let lastDate {
                        Text("Última: \(lastDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 6)
    }
}
