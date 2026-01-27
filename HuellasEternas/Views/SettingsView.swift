//
//  SettingsView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 20/11/25.
//

import SwiftUI
import StoreKit

struct SettingsView: View {

    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // Cambia estas URLs por las reales cuando las tengas
    private let privacyURL = URL(string: "https://insaneplatypusgames.wordpress.com/politica-de-privacidad-huellas-eternas/")!
    private let termsURL = URL(string: "https://insaneplatypusgames.wordpress.com/terminos-de-uso-huellas-eternas/")!
    private let supportURL = URL(string: "https://example.com/support")!

    var body: some View {
        List {
            subscriptionSection
            feedbackSection
            legalSection
            aboutSection
        }
        .navigationTitle("Ajustes")
        .listStyle(.insetGrouped)
    }

    // MARK: - Sections

    private var subscriptionSection: some View {
        Section("Suscripción") {
            HStack {
                Text("Estado")
                Spacer()
                Text(subscriptionManager.isPremium ? "Premium" : "Free")
                    .foregroundColor(subscriptionManager.isPremium ? .green : .secondary)
            }

            // Abre la gestión de suscripciones de Apple (Settings)
            Button {
                openManageSubscriptions()
            } label: {
                Label("Gestionar suscripción", systemImage: "creditcard")
            }

            // Útil para revisión y para que el usuario encuentre el paywall
            NavigationLink {
                PaywallView()
            } label: {
                Label("Ver Premium", systemImage: "crown.fill")
            }
        }
    }

    private var feedbackSection: some View {
        Section("Feedback") {
            Button {
                requestReview()
            } label: {
                Label("Valorar la app", systemImage: "star.bubble.fill")
            }

            Button {
                sendFeedbackEmail()
            } label: {
                Label("Enviar feedback", systemImage: "envelope.fill")
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Link(destination: privacyURL) {
                Label("Política de privacidad", systemImage: "hand.raised.fill")
            }
            Link(destination: termsURL) {
                Label("Términos de uso", systemImage: "doc.text.fill")
            }
            Link(destination: supportURL) {
                Label("Soporte", systemImage: "questionmark.circle.fill")
            }
        }
    }

    private var aboutSection: some View {
        Section("App") {
            HStack {
                Text("Versión")
                Spacer()
                Text(appVersionString)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func openManageSubscriptions() {
        // iOS provee este deep link para gestionar suscripciones
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        // StoreKit: pedir review. Apple decide si lo muestra o no.
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func sendFeedbackEmail() {
        // MVP: copia un mailto (abre Mail). Cambia el correo cuando quieras.
        let subject = "Feedback HuellasEternas"
        let body = "Hola, quería comentar lo siguiente:\n\n"
        let mail = "mailto:soporte@huellaseternas.app?subject=\(subject.urlEncoded)&body=\(body.urlEncoded)"

        if let url = URL(string: mail) {
            UIApplication.shared.open(url)
        }
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "\(version) (\(build))"
    }
}

// Helper para mailto (encoding simple)
private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

