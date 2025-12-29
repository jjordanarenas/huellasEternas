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
        """
        He creado este memorial para \(memorialName).
        Para verlo y encender una vela en su honor, abre la app “HuellasEternas” y pega este código en “Unirme a un memorial”:

        \(shareToken)
        """
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Comparte este memorial")
                            .font(.title3)
                            .bold()
                        Text("Invita a amigos y familia para que también puedan encender una vela en honor a \(memorialName).")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Código para unirse")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Text(shareToken)
                            .font(.system(.title3, design: .monospaced))
                            .bold()
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        Button {
                            UIPasteboard.general.string = shareToken
                            showCopiedAlert = true
                        } label: {
                            Label("Copiar", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                    }

                    Text("La otra persona abre la app y pega este código en “Unirme a un memorial”.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 10) {

                    Button {
                        openWhatsAppOrFallback()
                    } label: {
                        Label("Enviar por WhatsApp", systemImage: "message.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    // Share sheet estándar del sistema (siempre funciona)
                    ShareLink(item: shareText) {
                        Label("Compartir (más opciones)", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        dismiss()
                    } label: {
                        Text("Ahora no")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Spacer(minLength: 0)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
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

