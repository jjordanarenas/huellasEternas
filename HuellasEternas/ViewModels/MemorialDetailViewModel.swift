//
//  MemorialDetailViewModel.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 18/11/25.
//

import Foundation

// ViewModel específico para el detalle de un memorial
final class MemorialDetailViewModel: ObservableObject {
    
    // Memorial que estamos mostrando
    let memorial: Memorial
    
    // Servicio para hablar con Firestore sobre velas
    private let candleService: CandleService
    
    // Estado de la UI para el proceso de encender vela
    @Published var isLightingCandle: Bool = false      // para mostrar un indicador de carga si quieres
    @Published var candleSuccessMessage: String? = nil // para mostrar alert de éxito
    @Published var candleErrorMessage: String? = nil   // para mostrar alert de error

    // Estado para lista de velas
    @Published var candles: [Candle] = []
    @Published var isLoadingCandles: Bool = false

    init(memorial: Memorial, candleService: CandleService = CandleService()) {
        self.memorial = memorial
        self.candleService = candleService

        // 🔥 Nada más crearse el ViewModel,
        // lanzamos una tarea para cargar las velas.
        Task { [weak self] in
            await self?.loadCandles()
        }
    }

    // MARK: - Cargar velas desde Firestore

    /// Carga todas las velas de este memorial desde Firestore.
    @MainActor
    func loadCandles() async {
        guard !isLoadingCandles else { return }
        isLoadingCandles = true

        do {
            let memorialIdString = memorial.id.uuidString
            let fetched = try await candleService.fetchCandles(for: memorialIdString)
            self.candles = fetched
            print("--- Cargando velas para memorialId:", memorial.id.uuidString)
            print("--- Velas obtenidas:", fetched.count)
        } catch {
            print("Error al cargar velas: \(error)")
            // Si quieres, podrías reutilizar candleErrorMessage o crear otra propiedad específica
            self.candleErrorMessage = "No se han podido cargar las velas."
        }

        isLoadingCandles = false
    }

    /// Enciende una vela en Firestore con nombre y mensaje opcionales.
    /// - Parameters:
    ///   - fromName: nombre de la persona que enciende la vela (puede ser nil)
    ///   - message: mensaje que quiere dejar junto a la vela (puede ser nil)
    @MainActor
    func lightCandle(fromName: String?, message: String?) async {
        guard !isLightingCandle else { return }

        isLightingCandle = true
        candleErrorMessage = nil
        candleSuccessMessage = nil

        do {
            let memorialIdString = memorial.id.uuidString

            try await candleService.addCandle(
                memorialId: memorialIdString,
                fromName: (fromName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) ? nil : fromName,
                message: (message?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) ? nil : message
            )

            candleSuccessMessage = "Has encendido una vela en recuerdo de \(memorial.name)."
            // Tras añadir una nueva vela, recargamos la lista para que aparezca la nueva
            await loadCandles() 
        } catch {
            print("Error al encender vela: \(error)")
            candleErrorMessage = "No se ha podido encender la vela. Inténtalo de nuevo."
        }

        isLightingCandle = false
    }
}
