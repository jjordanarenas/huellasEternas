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

    // Suscripciones (para saber si es Premium)
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    // Límite de velas gratis al día para no Premium
    private let candleUsageManager = CandleUsageManager()

    // Mostrar Paywall cuando no queden velas gratis
    @State private var showPaywall = false

    @EnvironmentObject var memorialListVM: MemorialListViewModel
    @State private var showShareTip = false
    private let shareTipTracker = ShareTipTracker()


    // Inicializador personalizado que recibe un Memorial
    init(memorial: Memorial) {
        // Creamos el StateObject manualmente para pasar el memorial al ViewModel
        _viewModel = StateObject(wrappedValue: MemorialDetailViewModel(memorial: memorial))
    }

    private var memorial: Memorial {
        viewModel.memorial
    }

    private var memorialName: String {
        viewModel.memorial.name
    }

    private var shareToken: String {
        viewModel.memorial.shareToken
    }

    private var memorialId: UUID {
        viewModel.memorial.id
    }

    // URL que vamos a compartir. Más adelante esta URL puede ser real (landing o deep link).
    private var shareURL: URL {
        // OJO: cambia el dominio por el que vayas a usar realmente
        let token = viewModel.memorial.shareToken
        return URL(string: "https://huellas.app/m/\(token)")!
    }

    private var shareText: String {
        ShareComposer.memorialShareText(memorialName: memorial.name,
                                        shareToken: memorial.shareToken)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                basicInfoSection
                lightCandleButtonSection
                freeCandlesInfoSection
                candlesSection
                memoriesPlaceholderSection

                Spacer(minLength: 40)
            }
        }
        .navigationTitle(viewModel.memorial.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadCandles() }
        .toolbar { shareToolbar }
        .sheet(isPresented: $showCandleFormSheet) { candleFormSheet }
        .alert("Vela encendida", isPresented: $showSuccessAlert) { successAlertActions } message: { successAlertMessage }
        .alert("Error", isPresented: $showErrorAlert) { errorAlertActions } message: { errorAlertMessage }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(isPresented: $showShareTip) { shareTipSheet }
        .onAppear { handleShareTipOnAppear() }
        .onAppear { maybeShowShareTipIfNeeded() }
    }

    private var headerSection: some View {
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
    }

    private var basicInfoSection: some View {
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
    }

    private var lightCandleButtonSection: some View {
        Button {
            Task { await handleTapLightCandleButton() }
        } label: {
            Label("Encender una vela", systemImage: "candle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding(.horizontal)
        .padding(.top, 8)
        .disabled(viewModel.isLightingCandle)
    }

    private var remainingFreeCandlesToday: Int {
        candleUsageManager.remainingFreeCandlesToday()
    }

    @ViewBuilder
    private var freeCandlesInfoSection: some View {
        if !subscriptionManager.isPremium {
            let remaining = remainingFreeCandlesToday
            Text(
                remaining > 0
                ? "Te quedan \(remaining) velas gratis hoy."
                : "Has usado todas tus velas gratis de hoy."
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.horizontal)
        }
    }

    private var candlesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "candle.fill")
                    .foregroundColor(.orange)
                Text("Velas encendidas: \(viewModel.candles.count)")
                    .font(.headline)
            }

            candlesContent
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var candlesContent: some View {
        if viewModel.isLoadingCandles {
            ProgressView("Cargando velas…")
                .font(.subheadline)
                .padding(.top, 4)
        } else if viewModel.candles.isEmpty {
            Text("Aún no hay velas encendidas. Sé la primera persona en encender una en su honor.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.candles) { candle in
                    candleRow(candle)
                }
            }
            .padding(.top, 4)
        }
    }

    private func candleRow(_ candle: Candle) -> some View {
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

    private var shareToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ShareLink(item: shareText, subject: Text("Memorial para \(memorialName)")) {
                Label("Compartir (más opciones)", systemImage: "square.and.arrow.up")
            }
        }
    }

    private var candleFormSheet: some View {
        CandleFormView { name, message in
            Task {
                if !subscriptionManager.isPremium {
                    candleUsageManager.registerCandleUsage()
                }

                await viewModel.lightCandle(fromName: name, message: message)

                if viewModel.candleSuccessMessage != nil {
                    showSuccessAlert = true
                } else if viewModel.candleErrorMessage != nil {
                    showErrorAlert = true
                }
            }
        }
    }

    private var successAlertActions: some View {
        Button("Aceptar", role: .cancel) { }
    }
    private var successAlertMessage: some View {
        Text(viewModel.candleSuccessMessage ?? "Has encendido una vela.")
    }

    private var errorAlertActions: some View {
        Button("Aceptar", role: .cancel) { }
    }
    private var errorAlertMessage: some View {
        Text(viewModel.candleErrorMessage ?? "Ha ocurrido un error.")
    }

    private var shareTipSheet: some View {
        ShareMemorialTipSheet(memorialName: memorialName, shareToken: shareToken)
    }

    private var memoriesPlaceholderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recuerdos (pronto)")
                .font(.headline)

            Text("Aquí podrás añadir fotos, anécdotas y momentos especiales compartidos con \(viewModel.memorial.name).")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func handleShareTipOnAppear() {
        let memorialId = viewModel.memorial.id

        // 1) ¿Este memorial viene de "recién creado"?
        guard memorialListVM.pendingShareTipMemorialId == memorialId else {
            return
        }

        // 2) ¿Ya se mostró antes?
        guard !shareTipTracker.hasShownTip(for: memorialId) else {
            memorialListVM.pendingShareTipMemorialId = nil
            return
        }

        // 3) Analytics
        AnalyticsManager.shared.log(
            AEvent.memorialShared,
            ["channel": "tip_shown"]
        )

        // 4) Mostrar tip
        showShareTip = true
        shareTipTracker.markShown(for: memorialId)

        // 5) Limpieza
        memorialListVM.pendingShareTipMemorialId = nil
    }

   /* var body: some View {
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

                // Botón que abre el formulario de vela (con control de límite)
                Button {
                    Task {
                        await handleTapLightCandleButton()
                    }
                } label: {
                    Label("Encender una vela", systemImage: "candle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal)
                .padding(.top, 8)
                .disabled(viewModel.isLightingCandle)

                // Info sobre velas gratis restantes (solo para no Premium)
                if !subscriptionManager.isPremium {
                    let remaining = candleUsageManager.remainingFreeCandlesToday()
                    Text(
                        remaining > 0
                        ? "Te quedan \(remaining) velas gratis hoy."
                        : "Has usado todas tus velas gratis de hoy."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                }

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
                    item: shareText,
                    subject: Text("Memorial para \(memorialName)")
                ) {
                    Label("Compartir (más opciones)", systemImage: "square.and.arrow.up")
                }
            }
        }
        // Sheet con el formulario de vela
        .sheet(isPresented: $showCandleFormSheet) {
            CandleFormView { name, message in
                Task {
                    // Si NO es Premium, registramos que ha usado una vela gratis
                    if !subscriptionManager.isPremium {
                        candleUsageManager.registerCandleUsage()
                    }

                    await viewModel.lightCandle(fromName: name, message: message)

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
        // Paywall cuando se quedas sin velas gratis
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            // 1) ¿Este memorial es el que viene de “recién creado”?
            let shouldPrompt = (memorialListVM.pendingShareTipMemorialId == viewModel.memorial.id)

            guard shouldPrompt else { return }

            // 2) ¿Ya lo habíamos mostrado antes para este memorial?
            if !shareTipTracker.wasShown(for: viewModel.memorial.id) {
                AnalyticsManager.shared.log(AEvent.memorialShared, [
                    "channel": "tip_shown"
                ])
                showShareTip = true
                shareTipTracker.markShown(for: viewModel.memorial.id)
            }

            // 3) Limpieza: que no se vuelva a disparar si vuelves atrás/adelante
            memorialListVM.pendingShareTipMemorialId = nil
        }
        .sheet(isPresented: $showShareTip) {
            ShareMemorialTipSheet(memorialName: memorialName,
                                  shareToken: shareToken)
        }
        .onAppear {
            maybeShowShareTipIfNeeded()
        }
    }*/

    /// Formatea la fecha de la vela a algo tipo "hoy", "ayer" o fecha corta.
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// Decide qué hacer cuando el usuario pulsa "Encender una vela":
    /// - Si es Premium → abre formulario sin límite.
    /// - Si no es Premium:
    ///     - si le quedan velas gratis → abre formulario
    ///     - si no → muestra Paywall
    @MainActor
    private func handleTapLightCandleButton() async {
        // Si ya estamos en mitad de encender una vela, no hacemos nada
        guard !viewModel.isLightingCandle else { return }

        if subscriptionManager.isPremium {
            // Usuario Premium → sin límite
            showCandleFormSheet = true
            return
        }

        // Usuario no Premium → comprobar velas gratuitas restantes
        if candleUsageManager.canUseFreeCandle() {
            showCandleFormSheet = true
        } else {
            AnalyticsManager.shared.log(AEvent.paywallOpened, [
                "source": "candle_limit"
            ])
            
            // No le quedan velas gratis → mostrar Paywall
            showPaywall = true
        }
    }

    @MainActor
    private func maybeShowShareTipIfNeeded() {
        // 1) ¿Este memorial es el que el VM marcó como “recién creado”?
        guard memorialListVM.pendingShareTipMemorialId == memorialId else { return }

        // 2) ¿Ya se mostró alguna vez (persistente)?
        guard !shareTipTracker.hasShownTip(for: memorialId) else {
            // Limpia para no reintentar en futuros appears
            memorialListVM.pendingShareTipMemorialId = nil
            return
        }

        // 3) Marca como mostrado (persistente)
        shareTipTracker.markShown(for: memorialId)

        // 4) Limpia el “pending” para que no vuelva a disparar
        memorialListVM.pendingShareTipMemorialId = nil

        // 5) Muestra la sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showShareTip = true
        }
    }
}
