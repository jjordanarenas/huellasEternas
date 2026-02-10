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

    private let privacyURL = URL(string: "https://insaneplatypusgames.wordpress.com/politica-de-privacidad-huellas-eternas/")!
    private let termsURL = URL(string: "https://insaneplatypusgames.wordpress.com/terminos-de-uso-huellas-eternas/")!
    private let supportURL = URL(string: "https://insaneplatypusgames.wordpress.com/huellas-eternas-soporte/")!

    var body: some View {
        HuellasListContainer {
            List {
                subscriptionSection
                feedbackSection
                legalSection
                aboutSection
            }
            .navigationTitle("Ajustes")
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Sections

    private var subscriptionSection: some View {
        Section("Suscripción") {

            HStack {
                Label("Estado", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()

                Text(subscriptionManager.isPremium ? "Premium" : "Free")
                    .font(.subheadline)
                    .foregroundStyle(subscriptionManager.isPremium ? HuellasColor.primaryDark : HuellasColor.textSecondary)
            }
            .listRowBackground(HuellasColor.card)

            Button {
                openManageSubscriptions()
            } label: {
                Label("Gestionar suscripción", systemImage: "creditcard")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)

            NavigationLink {
                PaywallView()
            } label: {
                Label("Ver Premium", systemImage: "crown.fill")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)
        }
    }

    private var feedbackSection: some View {
        Section("Feedback") {

            Button {
                requestReview()
            } label: {
                Label("Valorar la app", systemImage: "star.bubble.fill")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)

            Button {
                sendFeedbackEmail()
            } label: {
                Label("Enviar feedback", systemImage: "envelope.fill")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)
        }
    }

    private var legalSection: some View {
        Section("Legal") {

            Link(destination: privacyURL) {
                Label("Política de privacidad", systemImage: "hand.raised.fill")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)

            Link(destination: termsURL) {
                Label("Términos de uso", systemImage: "doc.text.fill")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)

            Link(destination: supportURL) {
                Label("Soporte", systemImage: "questionmark.circle.fill")
                    .foregroundStyle(HuellasColor.textPrimary)
            }
            .listRowBackground(HuellasColor.card)
        }
    }

    private var aboutSection: some View {
        Section("App") {

            HStack {
                Label("Versión", systemImage: "info.circle.fill")
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()

                Text(appVersionString)
                    .foregroundStyle(HuellasColor.textSecondary)
            }
            .listRowBackground(HuellasColor.card)
        }
    }

    // MARK: - Actions

    private func openManageSubscriptions() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func sendFeedbackEmail() {
        let subject = "Feedback HuellasEternas"
        let body = "Hola, quería comentar lo siguiente:\n\n"
        let mail = "mailto:insaneplatypusgames@gmail.com?subject=\(subject.urlEncoded)&body=\(body.urlEncoded)"

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

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
