//
//  RootTabView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI

struct RootTabView: View {

    @EnvironmentObject var memorialListViewModel: MemorialListViewModel
    @State private var showPaywall = false

    @State private var showOnboarding = false
    @State private var pendingJoinToken: String? = nil
    @State private var showJoinSheet = false
    @State private var memorialPath = NavigationPath()

    private let onboardingState = OnboardingState()

    var body: some View {
        TabView {
            /*NavigationStack(path: $memorialPath) {
                MemorialListView(path: $memorialPath)
            }
            .tabItem {
                Label("Memoriales", systemImage: "pawprint.fill")
            }*/
            // TAB 1: Memoriales
            MemorialListView()
            .tabItem {
                Label("Memoriales", systemImage: "pawprint.fill")
            }


            NavigationStack {
                JournalView()
            }
            .tabItem {
                Label("Diario", systemImage: "book.closed.fill")
            }

            NavigationStack {
                RoutinesView()
            }
            .tabItem {
                Label("Rutinas", systemImage: "sparkles")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ajustes", systemImage: "gearshape.fill")
            }
        }
        .tint(HuellasColor.primaryDark)        // ✅ color global de acento
        .toolbarBackground(HuellasColor.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(.light)         // ✅ coherencia con tu icono
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
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
            NavigationStack {
                JoinMemorialView(prefilledInput: pendingJoinToken ?? "")
                    .environmentObject(memorialListViewModel)
            }
        }
    }

    private func handleUniversalLink(_ url: URL) {
        let path = url.pathComponents
        guard path.count >= 3 else { return }

        let section = path[1]
        let token = path[2]
        guard section == "m", !token.isEmpty else { return }

        pendingJoinToken = token
        showJoinSheet = true
    }
}
