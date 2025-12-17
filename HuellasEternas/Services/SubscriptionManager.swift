//
//  SubscriptionManager.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 3/12/25.
//


import Foundation
import StoreKit

/// Modelo simple para representar una opción de suscripción en la UI.
struct SubscriptionOption: Identifiable {
    let id: String
    let product: Product
    let displayName: String
    let displayPrice: String
    let isRecommended: Bool
}

/// Gestor central de suscripciones.
/// - Carga productos de StoreKit.
/// - Cuenta si el usuario es Premium.
/// - Inicia compras.
/// - Permite restaurar compras.
@MainActor
final class SubscriptionManager: ObservableObject {
    
    static let shared = SubscriptionManager()
    
    // Productos disponibles (mensual, anual, etc.)
    @Published private(set) var subscriptionOptions: [SubscriptionOption] = []
    
    // Estado actual de la suscripción
    @Published private(set) var isPremium: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published var lastErrorMessage: String? = nil
    
    private init() {
        // Al iniciar, intentamos cargar productos y estado de suscripción
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    // MARK: - Carga de productos
    
    /// Carga los productos de suscripción definidos en App Store Connect.
    func loadProducts() async {
        isLoading = true
        
        do {
            let productIds = SubscriptionProductID.allCases.map { $0.rawValue }
            let products = try await Product.products(for: productIds)
            
            // Mapeamos a SubscriptionOption para la UI
            let options: [SubscriptionOption] = products.map { product in
                SubscriptionOption(
                    id: product.id,
                    product: product,
                    displayName: product.displayName,
                    displayPrice: product.displayPrice,
                    isRecommended: product.id == SubscriptionProductID.yearly.rawValue // por ejemplo
                )
            }
            
            // Ordenamos para mostrar primero la mensual y luego la anual, o como prefieras
            self.subscriptionOptions = options.sorted(by: { $0.product.price < $1.product.price })
            
        } catch {
            print("❌ Error cargando productos de suscripción:", error)
            lastErrorMessage = "No se han podido cargar las opciones de suscripción."
        }
        
        isLoading = false
    }
    
    // MARK: - Estado de suscripción
    
    /// Actualiza la propiedad `isPremium` mirando las transacciones actuales.
    func updateSubscriptionStatus() async {
        do {
            var premium = false
            
            // Iteramos por las transacciones actuales para ver si hay alguna activa
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                // Comprobamos si este entitlement corresponde a uno de nuestros productos
                if SubscriptionProductID.allCases.map({ $0.rawValue }).contains(transaction.productID) {
                    // Además podrías comprobar fechas de expiración si quieres más control
                    premium = true
                    break
                }
            }
            
            self.isPremium = premium
            AnalyticsManager.shared.setUserProperty(premium ? "1" : "0", for: "is_premium")
        } catch {
            print("❌ Error actualizando estado de suscripción:", error)
            // Mantén isPremium como está si falla
        }
    }
    
    // MARK: - Comprar suscripción
    
    /// Inicia el flujo de compra para un producto de suscripción.
    func purchase(_ option: SubscriptionOption) async -> Bool {
        do {
            AnalyticsManager.shared.log(AEvent.purchaseStarted, [
                "product_id": option.product.id
            ])

            let result = try await option.product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Finalizamos la transacción
                    await transaction.finish()

                    AnalyticsManager.shared.log(AEvent.purchaseSuccess, [
                        "product_id": transaction.productID
                    ])

                    // Actualizamos estado
                    await updateSubscriptionStatus()
                    return true
                    
                case .unverified(_, let error):
                    print("❌ Transacción no verificada:", error.localizedDescription)
                    lastErrorMessage = "No se ha podido verificar la compra."
                    return false
                }
                
            case .userCancelled:
                // El usuario canceló la compra
                return false
                
            case .pending:
                // La compra está pendiente (por ejemplo, tiempo de aprobación)
                lastErrorMessage = "La compra está pendiente. Se activará cuando se complete."
                return false
                
            @unknown default:
                return false
            }
            
        } catch {
            print("❌ Error al iniciar compra:", error)
            lastErrorMessage = "No se ha podido completar la compra."
            return false
        }
    }
    
    // MARK: - Restaurar compras
    
    /// Restaura compras de suscripción (útil en ajustes).
    func restorePurchases() async {
        AnalyticsManager.shared.log(AEvent.restorePurchases)

        isLoading = true
        defer { isLoading = false }
        
        do {
            for await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else { continue }
                
                if SubscriptionProductID.allCases.map({ $0.rawValue }).contains(transaction.productID) {
                    // Hay al menos una suscripción activa
                    isPremium = true
                    return
                }
            }
            // Si no hemos encontrado ninguna, no es premium
            isPremium = false
        } catch {
            print("❌ Error al restaurar compras:", error)
            lastErrorMessage = "No se han podido restaurar tus compras."
        }
    }
}
