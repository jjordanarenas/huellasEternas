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
        HuellasScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    header

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pasos")
                            .font(.headline)
                            .foregroundStyle(HuellasColor.textPrimary)

                        ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                            Button {
                                toggleStep(index)
                            } label: {
                                HStack(alignment: .top, spacing: 10) {

                                    Image(systemName: completedSteps.contains(index) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(
                                            completedSteps.contains(index)
                                            ? HuellasColor.primaryDark
                                            : HuellasColor.divider
                                        )

                                    Text(step)
                                        .foregroundStyle(HuellasColor.textPrimary)

                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)

                            // ✅ Divider salvo el último
                            if index != routine.steps.indices.last {
                                Divider()
                                    .overlay(HuellasColor.divider)
                            }
                        }
                    }
                    .padding()
                    .background(HuellasColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(HuellasColor.divider, lineWidth: 1)
                    )

                    Button {
                        markCompleted()
                    } label: {
                        Label("Hecho", systemImage: "checkmark.seal.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(HuellasColor.primary)
                    .padding(.top, 4)

                    Text("Si hoy solo has podido hacer una parte, también cuenta.")
                        .font(.footnote)
                        .foregroundStyle(HuellasColor.textSecondary)
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
                        .foregroundStyle(HuellasColor.textPrimary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(HuellasColor.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(HuellasColor.divider, lineWidth: 1)
                        )
                        .padding(.bottom, 18)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut, value: showDoneToast)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: routine.iconSystemName)
                    .font(.system(size: 26))
                    .foregroundStyle(HuellasColor.primaryDark)

                Text(routine.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)
            }

            Text("Duración estimada: ~\(routine.estimatedMinutes) minutos")
                .font(.footnote)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
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
