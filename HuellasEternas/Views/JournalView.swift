//
//  JournalView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//


import SwiftUI

struct JournalView: View {
    var body: some View {
        Text("Aquí irá el Diario emocional.")
            .padding()
            .navigationTitle("Diario")
    }
}

struct RoutinesView: View {
    var body: some View {
        Text("Aquí irán las Rutinas para sobrellevar la pérdida.")
            .padding()
            .navigationTitle("Rutinas")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Aquí irán Ajustes, Cuenta y Suscripción.")
            .padding()
            .navigationTitle("Ajustes")
    }
}
