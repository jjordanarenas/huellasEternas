//
//  RootTabView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//


import SwiftUI

// Esta vista define la TabBar con las 4 secciones principales de la app.
struct RootTabView: View {
    
    // Accedemos al ViewModel compartido
    @EnvironmentObject var memorialListViewModel: MemorialListViewModel
    @State private var showPaywall = false

    @State private var showOnboarding = false
    @State private var pendingJoinToken: String? = nil
    @State private var showJoinSheet = false

    private let onboardingState = OnboardingState()

    var body: some View {
        TabView {
            
            // TAB 1: Lista de memoriales envuelta en NavigationStack
            NavigationStack {
                MemorialListView()
                /* 
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            Button("Premium") {
                                AnalyticsManager.shared.log(AEvent.paywallOpened, [
                                    "source": "premium_button"
                                ])
                                showPaywall = true
                            }
                        }
                    }
                */
            }
            .tabItem {
                Label("Memoriales", systemImage: "pawprint.fill")
            }
            
            // TAB 2: Diario (por ahora placeholder)
            NavigationStack {
                JournalView()
            }
            .tabItem {
                Label("Diario", systemImage: "book.closed.fill")
            }
            
            // TAB 3: Rutinas (placeholder)
            NavigationStack {
                RoutinesView()
            }
            .tabItem {
                Label("Rutinas", systemImage: "sparkles")
            }
            
            // TAB 4: Ajustes / Perfil / Suscripción (placeholder)
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ajustes", systemImage: "gearshape.fill")
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            // Si no lo ha completado, lo mostramos
            showOnboarding = !onboardingState.isCompleted
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingFlowView()
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
            guard let url = activity.webpageURL else { return }
            handleUniversalLink(url)
        }
        .sheet(isPresented: $showJoinSheet) {
            // Ideal: tu JoinMemorialView acepte un token inicial
            JoinMemorialView(prefilledInput: pendingJoinToken ?? "")
                .environmentObject(memorialListViewModel)
        }
    }

    private func handleUniversalLink(_ url: URL) {
        // Ejemplo: https://huellaseternas.app/m/AB12CD34
        let path = url.pathComponents   // ["/", "m", "AB12CD34"]
        guard path.count >= 3 else { return }

        let section = path[1]
        let token = path[2]

        guard section == "m", !token.isEmpty else { return }

        pendingJoinToken = token
        showJoinSheet = true
    }
}
