//
//  MemorialDetailView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI

struct MemorialDetailView: View {

    // Ahora no guardamos el memorial directamente,
    // sino un ViewModel que envuelve el memorial.
    @StateObject private var viewModel: MemorialDetailViewModel

    // Control del sheet del formulario de vela
    @State private var showCandleFormSheet = false

    // Estado local para simular el encendido de vela
    @State private var showCandleAlert = false

    // Propiedad @State para controlar la presentación de alerts
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false

    // Inicializador personalizado que recibe un Memorial
    init(memorial: Memorial) {
        // Creamos el StateObject manualmente para pasar el memorial al ViewModel
        _viewModel = StateObject(wrappedValue: MemorialDetailViewModel(memorial: memorial))
    }

    // URL que vamos a compartir. Más adelante esta URL puede ser real (landing o deep link).
    private var shareURL: URL {
        // OJO: cambia el dominio por el que vayas a usar realmente
        let token = viewModel.memorial.shareToken
        return URL(string: "https://huellas.app/m/\(token)")!
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Header con "foto" y nombre (placeholder)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 180)

                    VStack {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.9))
                        Text(viewModel.memorial.name)
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)

                // Info básica
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.memorial.name)
                        .font(.title2)
                        .bold()

                    Text(viewModel.memorial.petType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let quote = viewModel.memorial.shortQuote {
                        Text("“\(quote)”")
                            .italic()
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Botón que abre el formulario de vela
                Button {
                    showCandleFormSheet = true
                } label: {
                    Label("Encender una vela", systemImage: "candle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal)
                .padding(.top, 8)
                .disabled(viewModel.isLightingCandle) // por si algún día quieres bloquear durante el proceso

                // 🔥 BLOQUE DE VELAS: contador + lista
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "candle.fill")
                            .foregroundColor(.orange)
                        Text("Velas encendidas: \(viewModel.candles.count)")
                            .font(.headline)
                    }

                    if viewModel.isLoadingCandles {
                        // Indicador de carga mientras traemos las velas
                        ProgressView("Cargando velas…")
                            .font(.subheadline)
                            .padding(.top, 4)
                    } else if viewModel.candles.isEmpty {
                        Text("Aún no hay velas encendidas. Sé la primera persona en encender una en su honor.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    } else {
                        // Lista simple de velas (las más recientes primero)
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.candles) { candle in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(candle.fromName ?? "Persona anónima")
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        Text(formatDate(candle.createdAt))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    if let message = candle.message, !message.isEmpty {
                                        Text(message)
                                            .font(.subheadline)
                                    } else {
                                        Text("Encendió una vela en silencio.")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                // Placeholder de futuros contenidos
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recuerdos (pronto)")
                        .font(.headline)

                    Text("Aquí podrás añadir fotos, anécdotas y momentos especiales compartidos con \(viewModel.memorial.name).")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()

                Spacer(minLength: 40)
            }
        }
        .navigationTitle(viewModel.memorial.name)
        .navigationBarTitleDisplayMode(.inline)
        // 👇 Esto es un extra por si quieres asegurarte de
        // recargar cuando la vista aparece (aunque el init ya lo hace)
        .task {
            await viewModel.loadCandles()
        }
        // 👇 Añadimos toolbar con botón compartir
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: shareURL,
                    subject: Text("Memorial para \(viewModel.memorial.name)"),
                    message: Text("He creado este memorial para \(viewModel.memorial.name). Puedes verlo y encender una vela en su honor: \(shareURL.absoluteString)")
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        // Sheet con el formulario de vela
        .sheet(isPresented: $showCandleFormSheet) {
            CandleFormView { name, message in
                // Cuando el usuario confirma en el formulario,
                // aquí se llama a la función del ViewModel (async).
                Task {
                    await viewModel.lightCandle(fromName: name, message: message)

                    // Decidimos qué alert mostrar según el estado del ViewModel
                    if viewModel.candleSuccessMessage != nil {
                        showSuccessAlert = true
                    } else if viewModel.candleErrorMessage != nil {
                        showErrorAlert = true
                    }
                }
            }
        }

        // Alert de éxito
        .alert(
            "Vela encendida",
            isPresented: $showSuccessAlert,
            actions: {
                Button("Aceptar", role: .cancel) { }
            },
            message: {
                Text(viewModel.candleSuccessMessage ?? "Has encendido una vela.")
            }
        )

        // Alert de error
        .alert(
            "Error",
            isPresented: $showErrorAlert,
            actions: {
                Button("Aceptar", role: .cancel) { }
            },
            message: {
                Text(viewModel.candleErrorMessage ?? "Ha ocurrido un error.")
            }
        )
    }

    /// Formatea la fecha de la vela a algo tipo "hoy", "ayer" o fecha corta.
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
