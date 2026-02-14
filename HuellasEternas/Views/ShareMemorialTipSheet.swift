//
//  ShareMemorialTipSheet.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI
import UIKit

struct ShareMemorialTipSheet: View {
    @Environment(\.dismiss) private var dismiss

    let memorialName: String
    let shareToken: String

    @State private var showCopiedAlert = false
    @State private var showWhatsAppFallbackAlert = false

    private var shareText: String {
        "He creado un memorial para \(memorialName) en HuellasEternas.\n\n" +
        "Para unirte, abre la app y ve a “Unirme a un memorial”, y pega este código:\n" +
        "\(shareToken)"
    }

    var body: some View {
        NavigationStack {
            HuellasScreen {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    codeCard
                    actionButtons
                    Spacer(minLength: 0)
                }
                .padding()
                .navigationTitle("Compartir")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Cerrar") { dismiss() }
                            .foregroundStyle(HuellasColor.primaryDark)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .alert("Copiado", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("El código \(shareToken) se ha copiado al portapapeles.")
        }
        .alert("WhatsApp no disponible", isPresented: $showWhatsAppFallbackAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No se ha podido abrir WhatsApp. Usa “Compartir (más opciones)”.")
        }
    }

    // MARK: - UI

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(HuellasColor.primaryDark)

            VStack(alignment: .leading, spacing: 6) {
                Text("Comparte este memorial")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(HuellasColor.textPrimary)

                Text("Invita a amigos y familia para que también puedan encender una vela en honor a \(memorialName).")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)
            }

            Spacer()
        }
    }

    private var codeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Código para unirse")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HuellasColor.primaryDark)

                    Text(shareToken)
                        .font(.system(.title3, design: .monospaced))
                        .bold()
                        .foregroundStyle(HuellasColor.textPrimary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(HuellasColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(HuellasColor.divider, lineWidth: 1)
                )

                Spacer(minLength: 0)

                Button {
                    UIPasteboard.general.string = shareToken
                    showCopiedAlert = true
                    Haptics.success()
                } label: {
                    Label("Copiar", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .tint(HuellasColor.primaryDark)
            }

            Text("La otra persona abre la app y pega este código en “Unirme a un memorial”.")
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

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                openWhatsAppOrFallback()
                Haptics.light()
            } label: {
                Label("Enviar por WhatsApp", systemImage: "message.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(HuellasColor.primary) // CTA dorado

            ShareLink(item: shareText) {
                Label("Compartir (más opciones)", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(HuellasColor.primaryDark)

            Button {
                dismiss()
            } label: {
                Text("Ahora no")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(HuellasColor.primaryDark)
        }
        .padding(.top, 4)
    }

    // MARK: - WhatsApp

    private func openWhatsAppOrFallback() {
        let encoded = shareText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "whatsapp://send?text=\(encoded)"

        guard let url = URL(string: urlString) else {
            showWhatsAppFallbackAlert = true
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            AnalyticsManager.shared.log(AEvent.memorialShared, [
                "channel": "whatsapp"
            ])
            UIApplication.shared.open(url)
        } else {
            showWhatsAppFallbackAlert = true
        }
    }
}
