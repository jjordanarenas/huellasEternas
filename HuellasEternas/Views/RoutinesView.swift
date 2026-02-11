//
//  RoutinesView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI

struct RoutinesView: View {

    private let routines = RoutineCatalog.all
    private let progressStore = RoutineProgressStore()

    var body: some View {
        HuellasListContainer {
            List {

                // Intro (card)
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(HuellasColor.primaryDark)

                            Text("Rutinas")
                                .font(.headline)
                                .foregroundStyle(HuellasColor.textPrimary)

                            Spacer()
                        }

                        Text("Rutinas cortas para acompañarte en días difíciles. No tienes que hacerlas perfectas; solo empezar.")
                            .font(.footnote)
                            .foregroundStyle(HuellasColor.textSecondary)
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(HuellasColor.card)

                Section("Rutinas") {
                    ForEach(routines) { routine in
                        NavigationLink {
                            RoutineDetailView(routine: routine, progressStore: progressStore)
                        } label: {
                            RoutineRowView(
                                routine: routine,
                                count: progressStore.completionCount(for: routine.id),
                                lastDate: progressStore.lastCompletedAt(for: routine.id)
                            )
                        }
                        .listRowBackground(HuellasColor.card)
                    }
                }
            }
            .navigationTitle("Rutinas")
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden) // ✅ evita blancos
        }
    }
}

// MARK: - Row

private struct RoutineRowView: View {
    let routine: Routine
    let count: Int
    let lastDate: Date?

    var body: some View {
        HStack(spacing: 12) {

            // Icono con círculo (consistente con MemorialRow)
            ZStack {
                Circle()
                    .fill(HuellasColor.backgroundSecondary)

                Circle()
                    .stroke(HuellasColor.divider, lineWidth: 1)

                Image(systemName: routine.iconSystemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(HuellasColor.primaryDark)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(routine.title)
                        .font(.headline)
                        .foregroundStyle(HuellasColor.textPrimary)

                    Spacer()

                    Text("~\(routine.estimatedMinutes) min")
                        .font(.caption)
                        .foregroundStyle(HuellasColor.textSecondary)
                }

                Text(routine.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)

                // Progreso (simple y discreto)
                if count > 0 || lastDate != nil {
                    HStack(spacing: 10) {
                        if count > 0 {
                            Label("Hecha \(count)x", systemImage: "checkmark.circle.fill")
                                .labelStyle(.titleAndIcon)
                                .font(.caption)
                                .foregroundStyle(HuellasColor.primaryDark)
                        }

                        if let lastDate {
                            Text("Última: \(lastDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(HuellasColor.textSecondary)
                        }
                    }
                    .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}
