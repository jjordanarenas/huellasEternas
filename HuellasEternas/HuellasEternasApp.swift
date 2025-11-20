//
//  HuellasEternasApp.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import SwiftUI
import FirebaseCore

// Este es el punto de entrada de la app (equivalente a @UIApplicationMain en UIKit)
@main
struct HuellasEternasApp: App {

    // @StateObject crea una instancia del ViewModel que vivirá
    // mientras viva la app. Es el "estado fuente de la verdad".
    @StateObject private var memorialListViewModel = MemorialListViewModel()

    init() {
        // Inicializa Firebase cuando arranca la app
        FirebaseApp.configure()
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
