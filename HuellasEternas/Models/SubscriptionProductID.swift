//
//  SubscriptionProductID.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 3/12/25.
//


import Foundation

/// Identificadores de productos de suscripción en App Store Connect.
/// Cámbialos por los que crees allí.
enum SubscriptionProductID: String, CaseIterable {
    case monthly = "huellas.premium.monthly"
    case yearly  = "huellas.premium.yearly"
}
