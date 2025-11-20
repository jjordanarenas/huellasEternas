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
    
    var body: some View {
        TabView {
            
            // TAB 1: Lista de memoriales envuelta en NavigationStack
            NavigationStack {
                MemorialListView()
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
    }
}
