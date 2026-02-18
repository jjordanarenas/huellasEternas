//
//  MemorialDetailView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI

struct MemorialDetailView: View {

    @StateObject private var viewModel: MemorialDetailViewModel

    @State private var showCandleFormSheet = false
    @State private var showCandleAlert = false

    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false

    @StateObject private var subscriptionManager = SubscriptionManager.shared
    private let candleUsageManager = CandleUsageManager()
    @State private var showPaywall = false

    @EnvironmentObject var memorialListVM: MemorialListViewModel
    @State private var showShareTip = false

    @StateObject private var memoriesVM: MemoriesViewModel
    @State private var showAddMemorySheet = false

    private let shareTipTracker = ShareTipTracker()

    init(memorial: Memorial) {
        _viewModel = StateObject(wrappedValue: MemorialDetailViewModel(memorial: memorial))
        _memoriesVM = StateObject(wrappedValue: MemoriesViewModel(memorialId: memorial.id.uuidString))
    }

    private var memorial: Memorial { viewModel.memorial }
    private var memorialName: String { memorial.name }
    private var shareToken: String { memorial.shareToken }
    private var memorialId: UUID { memorial.id }

    private var shareText: String {
        ShareComposer.memorialShareText(memorialName: memorial.name,
                                        shareToken: memorial.shareToken)
    }

    var body: some View {
        HuellasScreen {
            ScrollView {
                VStack(spacing: 14) {

                    headerSection

                    basicInfoSection

                    lightCandleButtonSection

                    freeCandlesInfoSection

                    candlesSection

                    memoriesSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .background(HuellasColor.background) // ✅ refuerzo anti-blancos
            .navigationTitle(memorialName)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadCandles()
                await memoriesVM.load()
            }
            .toolbar { shareToolbar }
            .sheet(isPresented: $showCandleFormSheet) { candleFormSheet }
            .alert("Vela encendida", isPresented: $showSuccessAlert) { successAlertActions } message: { successAlertMessage }
            .alert("Error", isPresented: $showErrorAlert) { errorAlertActions } message: { errorAlertMessage }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(isPresented: $showShareTip) { shareTipSheet }
            .onAppear { maybeShowShareTipIfNeeded() }
        }
    }

    // MARK: - UI Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: memorial.petType.systemImage)
                    .font(.system(size: 34))
                    .foregroundStyle(HuellasColor.primaryDark)

                VStack(alignment: .leading, spacing: 3) {
                    Text(memorialName)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(HuellasColor.textPrimary)

                    Text(memorial.petType.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(HuellasColor.textSecondary)
                }

                Spacer()
            }

            if let quote = memorial.shortQuote,
               !quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("“\(quote)”")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(HuellasColor.textSecondary)
            }
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
    }

    private var basicInfoSection: some View {
        // Si más adelante añades fechas, aquí queda perfecto.
        EmptyView()
    }

    private var lightCandleButtonSection: some View {
        Button {
            Task { await handleTapLightCandleButton() }
        } label: {
            Label("Encender una vela", systemImage: "candle.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(HuellasColor.primary) // ✅ dorado del icono
        .disabled(viewModel.isLightingCandle)
        .padding(.top, 2)
    }

    private var remainingFreeCandlesToday: Int {
        candleUsageManager.remainingFreeCandlesToday()
    }

    @ViewBuilder
    private var freeCandlesInfoSection: some View {
        if !subscriptionManager.isPremium {
            let remaining = remainingFreeCandlesToday

            HStack(spacing: 8) {
                Image(systemName: remaining > 0 ? "gift.fill" : "lock.fill")
                    .foregroundStyle(HuellasColor.primaryDark)

                Text(
                    remaining > 0
                    ? "Te quedan \(remaining) velas gratis hoy."
                    : "Has usado todas tus velas gratis de hoy."
                )
                .font(.caption)
                .foregroundStyle(HuellasColor.textSecondary)

                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)
        }
    }

    private var candlesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "candle.fill")
                    .foregroundStyle(HuellasColor.primaryDark)

                Text("Velas encendidas: \(viewModel.candles.count)")
                    .font(.headline)
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()
            }

            candlesContent
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
        .padding(.top, 8)
    }

    @ViewBuilder
    private var candlesContent: some View {
        if viewModel.isLoadingCandles {
            ProgressView("Cargando velas…")
                .tint(HuellasColor.primaryDark)
                .font(.subheadline)
                .padding(.top, 2)

        } else if viewModel.candles.isEmpty {
            Text("Aún no hay velas encendidas. Sé la primera persona en encender una en su honor.")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
                .padding(.top, 2)

        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.candles) { candle in
                    candleRow(candle)
                }
            }
            .padding(.top, 2)
        }
    }

    private func candleRow(_ candle: Candle) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text((candle.fromName?.isEmpty == false) ? (candle.fromName ?? "") : "Persona anónima")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()

                Text(formatDate(candle.createdAt))
                    .font(.caption)
                    .foregroundStyle(HuellasColor.textSecondary)
            }

            if let message = candle.message, !message.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textPrimary)
            } else {
                Text("Encendió una vela en silencio.")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)
            }
        }
        .padding(10)
        .background(HuellasColor.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(HuellasColor.divider.opacity(0.8), lineWidth: 1)
        )
    }

    private var memoriesPlaceholderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recuerdos (pronto)")
                .font(.headline)
                .foregroundStyle(HuellasColor.textPrimary)

            Text("Aquí podrás añadir fotos, anécdotas y momentos especiales compartidos con \(memorialName).")
                .font(.subheadline)
                .foregroundStyle(HuellasColor.textSecondary)
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
        .padding(.top, 8)
    }

    // MARK: - Toolbar / Sheets / Alerts

    private var shareToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ShareLink(item: shareText, subject: Text("Memorial para \(memorialName)")) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(HuellasColor.primaryDark)
            }
            .tint(HuellasColor.primaryDark) // ✅ color consistente
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

    // MARK: - Helpers / Logic

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    @MainActor
    private func handleTapLightCandleButton() async {
        guard !viewModel.isLightingCandle else { return }

        if subscriptionManager.isPremium {
            showCandleFormSheet = true
            return
        }

        if candleUsageManager.canUseFreeCandle() {
            showCandleFormSheet = true
        } else {
            AnalyticsManager.shared.log(AEvent.paywallOpened, [
                "source": "candle_limit"
            ])
            showPaywall = true
        }
    }

    @MainActor
    private func maybeShowShareTipIfNeeded() {
        guard memorialListVM.pendingShareTipMemorialId == memorialId else { return }

        guard !shareTipTracker.hasShownTip(for: memorialId) else {
            memorialListVM.pendingShareTipMemorialId = nil
            return
        }

        shareTipTracker.markShown(for: memorialId)
        memorialListVM.pendingShareTipMemorialId = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showShareTip = true
        }
    }

    private var memoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recuerdos")
                    .font(.headline)
                    .foregroundStyle(HuellasColor.textPrimary)

                Spacer()

                Button {
                    showAddMemorySheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(HuellasColor.primaryDark)
                }
            }

            if memoriesVM.isLoading {
                ProgressView("Cargando recuerdos…")
                    .tint(HuellasColor.primaryDark)
                    .font(.subheadline)
                    .padding(.top, 2)

            } else if let msg = memoriesVM.errorMessage {
                Text(msg)
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)

            } else if memoriesVM.memories.isEmpty {
                Text("Añade fotos, anécdotas y momentos especiales para que este memorial sea aún más tuyo.")
                    .font(.subheadline)
                    .foregroundStyle(HuellasColor.textSecondary)

            } else {
                VStack(spacing: 10) {
                    ForEach(memoriesVM.memories) { memory in
                        MemoryCardView(memory: memory)
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task { await memoriesVM.delete(memory: memory) }
                                } label: {
                                    Label("Borrar", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding()
        .background(HuellasColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(HuellasColor.divider, lineWidth: 1)
        )
        .padding(.top, 8)
        .sheet(isPresented: $showAddMemorySheet) {
            AddMemoryView { title, text, photoData in
                let ok = await memoriesVM.add(title: title, text: text, photoData: photoData)

                if !ok, memoriesVM.shouldShowPaywall {
                    showPaywall = true
                }

                if ok { Haptics.success() } else { Haptics.error() }
                return ok
            }
        }
    }
}
