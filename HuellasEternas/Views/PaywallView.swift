//
//  PaywallView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 3/12/25.
//

import SwiftUI
import StoreKit

/// Pantalla simple de paywall para ofrecer Huellas Premium.
struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    @State private var isPurchasing: Bool = false
    @State private var purchaseSuccess: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            HuellasScreen {
                VStack(spacing: 0) {

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {

                            header

                            benefitsCard

                            Divider()
                                .overlay(HuellasColor.divider)
                                .padding(.vertical, 8)

                            subscriptionOptionsBlock

                            restoreButton

                            legalNote
                        }
                        .padding()
                    }

                    bottomCloseButton
                }
                .navigationTitle("Hazte Premium")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { topCloseToolbar }
                .alert(isPresented: $showAlert) { paywallAlert }
            }
        }
    }

    // MARK: - UI blocks

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Huellas Premium")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Haz que el recuerdo de tu mascota sea aún más especial.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .padding(.bottom, 8)
    }

    private var benefitsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            PaywallBenefitRow(text: "Mensajes de ánimo con IA ilimitados", systemImage: "sparkles")
            PaywallBenefitRow(text: "Memoriales con fotos ilimitadas", systemImage: "photo.on.rectangle")
            PaywallBenefitRow(text: "Velas especiales y dedicatorias largas", systemImage: "candle.fill")
            PaywallBenefitRow(text: "Diario emocional avanzado y protegido", systemImage: "lock.shield")
        }
        .font(.subheadline)
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var subscriptionOptionsBlock: some View {
        // ✅ Importante: NO usar ProgressView("texto") para evitar el “rectángulo blanco”.
        if subscriptionManager.isLoading && subscriptionManager.subscriptionOptions.isEmpty {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(HuellasColor.primaryDark)
                    .scaleEffect(1.1)

                Text("Cargando opciones de suscripción…")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

        } else if subscriptionManager.subscriptionOptions.isEmpty {
            Text("No se han podido cargar las opciones de suscripción. Inténtalo más tarde.")
                .font(.footnote)
                .foregroundStyle(HuellasColor.textSecondary)

        } else {
            VStack(spacing: 12) {
                ForEach(subscriptionManager.subscriptionOptions) { option in
                    SubscriptionOptionRow(
                        option: option,
                        isPurchasing: isPurchasing
                    ) {
                        Task { await purchase(option) }
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    private var restoreButton: some View {
        Button {
            Task {
                await subscriptionManager.restorePurchases()
                if subscriptionManager.isPremium {
                    purchaseSuccess = true
                    showAlert = true
                } else {
                    subscriptionManager.lastErrorMessage = "No se han encontrado suscripciones activas."
                    showAlert = true
                }
            }
        } label: {
            Text("Restaurar compras")
                .font(.footnote)
                .foregroundStyle(HuellasColor.primaryDark)
        }
        .padding(.top, 16)
    }

    private var legalNote: some View {
        Text("La suscripción se puede cancelar en cualquier momento desde Ajustes > Suscripciones.")
            .font(.caption)
            .foregroundStyle(HuellasColor.textSecondary)
            .padding(.top, 2)
    }

    private var bottomCloseButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cerrar")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(HuellasColor.primaryDark)
        .padding()
        .background(HuellasColor.background)
    }

    private var topCloseToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(HuellasColor.primaryDark)
            }
        }
    }

    private var paywallAlert: Alert {
        if purchaseSuccess || subscriptionManager.isPremium {
            return Alert(
                title: Text("Gracias por tu apoyo"),
                message: Text("Tu suscripción a Huellas Premium está activa."),
                dismissButton: .default(Text("Aceptar"), action: { dismiss() })
            )
        } else {
            return Alert(
                title: Text("No se pudo completar"),
                message: Text(subscriptionManager.lastErrorMessage ?? "Ha ocurrido un error."),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }

    // MARK: - Purchase

    private func purchase(_ option: SubscriptionOption) async {
        guard !isPurchasing else { return }
        isPurchasing = true

        let success = await subscriptionManager.purchase(option)
        purchaseSuccess = success
        isPurchasing = false

        if success || subscriptionManager.lastErrorMessage != nil {
            showAlert = true
        }
    }
}

/// Fila de beneficio del paywall (reutilizable y alineada con tu paleta)
private struct PaywallBenefitRow: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(HuellasColor.primaryDark)
            Text(text)
                .foregroundStyle(HuellasColor.textPrimary)
            Spacer()
        }
    }
}

/// Fila para cada opción de suscripción (mensual / anual).
struct SubscriptionOptionRow: View {

    let option: SubscriptionOption
    let isPurchasing: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {

                    HStack(spacing: 8) {
                        Text(option.displayName)
                            .font(.headline)
                            .foregroundStyle(HuellasColor.textPrimary)

                        if option.isRecommended {
                            Text("Más popular")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(HuellasColor.backgroundSecondary)
                                .foregroundStyle(HuellasColor.primaryDark)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(HuellasColor.divider, lineWidth: 1)
                                )
                        }
                    }

                    Text(option.displayPrice)
                        .font(.subheadline)
                        .foregroundStyle(HuellasColor.textSecondary)
                }

                Spacer()

                if isPurchasing {
                    ProgressView()
                        .tint(HuellasColor.primaryDark)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(HuellasColor.textSecondary)
                }
            }
            .padding()
            .background(HuellasColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(HuellasColor.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}
