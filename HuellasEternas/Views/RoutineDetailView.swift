//
//  RoutineDetailView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 27/1/26.
//


import SwiftUI

struct RoutineDetailView: View {

    let routine: Routine
    let progressStore: RoutineProgressStore

    @State private var completedSteps: Set<Int> = []
    @State private var showDoneToast = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                header

                VStack(alignment: .leading, spacing: 12) {
                    Text("Pasos")
                        .font(.headline)

                    ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                        Button {
                            toggleStep(index)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: completedSteps.contains(index) ? "checkmark.circle.fill" : "circle")
                                Text(step)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)

                        Divider()
                    }
                }

                Button {
                    markCompleted()
                } label: {
                    Label("Hecho", systemImage: "checkmark.seal.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)

                // Un pequeño refuerzo emocional (MVP)
                Text("Si hoy solo has podido hacer una parte, también cuenta.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 6)

                Spacer(minLength: 8)
            }
            .padding()
        }
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showDoneToast {
                Text("Rutina completada ✅")
                    .font(.subheadline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.bottom, 18)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showDoneToast)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: routine.iconSystemName)
                    .font(.system(size: 26))
                Text(routine.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text("Duración estimada: ~\(routine.estimatedMinutes) minutos")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private func toggleStep(_ index: Int) {
        if completedSteps.contains(index) {
            completedSteps.remove(index)
        } else {
            completedSteps.insert(index)
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func markCompleted() {
        progressStore.markCompleted(id: routine.id)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        showDoneToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showDoneToast = false
        }
    }
}
