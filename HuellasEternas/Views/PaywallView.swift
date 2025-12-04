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
    
    // Usaremos el singleton como StateObject para observar cambios
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var isPurchasing: Bool = false
    @State private var purchaseSuccess: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Huellas Premium")
                                .font(.largeTitle)
                                .bold()
                            Text("Haz que el recuerdo de tu mascota sea aún más especial.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 8)
                        
                        // Beneficios
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Mensajes de ánimo con IA ilimitados", systemImage: "sparkles")
                            Label("Memoriales con fotos ilimitadas", systemImage: "photo.on.rectangle")
                            Label("Velas especiales y dedicatorias largas", systemImage: "candle.fill")
                            Label("Diario emocional avanzado y protegido", systemImage: "lock.shield")
                        }
                        .font(.subheadline)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Opciones de suscripción
                        if subscriptionManager.isLoading && subscriptionManager.subscriptionOptions.isEmpty {
                            ProgressView("Cargando opciones de suscripción…")
                                .padding(.vertical, 16)
                        } else if subscriptionManager.subscriptionOptions.isEmpty {
                            Text("No se han podido cargar las opciones de suscripción. Inténtalo más tarde.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
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
                        
                        // Restaurar compras
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
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                }
                
                // Botón cerrar
                Button {
                    dismiss()
                } label: {
                    Text("Cerrar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("Hazte Premium")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                if purchaseSuccess || subscriptionManager.isPremium {
                    return Alert(
                        title: Text("Gracias por tu apoyo"),
                        message: Text("Tu suscripción a Huellas Premium está activa."),
                        dismissButton: .default(Text("Aceptar"), action: {
                            dismiss()
                        })
                    )
                } else {
                    return Alert(
                        title: Text("No se pudo completar"),
                        message: Text(subscriptionManager.lastErrorMessage ?? "Ha ocurrido un error."),
                        dismissButton: .default(Text("Aceptar"))
                    )
                }
            }
        }
    }
    
    private func purchase(_ option: SubscriptionOption) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        
        let success = await subscriptionManager.purchase(option)
        purchaseSuccess = success
        isPurchasing = false
        
        if success {
            showAlert = true
        } else if subscriptionManager.lastErrorMessage != nil {
            showAlert = true
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.displayName)
                        .font(.headline)
                    Text(option.displayPrice)
                        .font(.subheadline)
                    
                    if option.isRecommended {
                        Text("Más popular")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                Spacer()
                if isPurchasing {
                    ProgressView()
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
