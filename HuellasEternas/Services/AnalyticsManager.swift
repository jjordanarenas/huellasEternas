//
//  AnalyticsManager.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 17/12/25.
//

import Foundation
import FirebaseAnalytics

enum AEvent {
    static let memorialCreated   = "memorial_created"
    static let candleLit         = "candle_lit"
    static let aiGenerated       = "ai_message_generated"
    static let paywallOpened     = "paywall_opened"
    static let purchaseStarted   = "purchase_started"
    static let purchaseSuccess   = "purchase_success"
    static let restorePurchases  = "restore_purchases"
    static let memorialShared    = "memorial_shared"
    static let joinMemorial      = "join_memorial"
}

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}

    func log(_ name: String, _ params: [String: Any] = [:]) {
        Analytics.logEvent(name, parameters: params)
    }

    /// Útil para marcar propiedades globales tipo premium/no premium.
    func setUserProperty(_ value: String?, for name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
