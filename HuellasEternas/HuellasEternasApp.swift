//
//  HuellasEternasApp.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck

// Este es el punto de entrada de la app (equivalente a @UIApplicationMain en UIKit)
@main
struct HuellasEternasApp: App {

    // @StateObject crea una instancia del ViewModel que vivirá
    // mientras viva la app. Es el "estado fuente de la verdad".
    @StateObject private var memorialListViewModel = MemorialListViewModel()

    init() {
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #endif
        // Inicializa Firebase cuando arranca la app
        FirebaseApp.configure()
        signInAnonymouslyIfNeeded()
        HuellasTheme.apply()
    }

    private func signInAnonymouslyIfNeeded() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    print("❌ Error en login anónimo: \(error)")
                } else {
                    print("✅ Usuario anónimo autenticado: \(result?.user.uid ?? "?")")
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            // RootTabView será la vista raíz con la TabBar.
            // environmentObject inyecta el ViewModel en el árbol de vistas,
            // para que cualquier vista hija pueda acceder a él con @EnvironmentObject.
            RootTabView()
                .environmentObject(memorialListViewModel)
        }
    }
}
