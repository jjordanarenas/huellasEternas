//
//  ShareTipTracker.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import Foundation

/// Guarda localmente si ya mostramos el tip de compartir para un memorial.
/// Usamos UserDefaults porque es simple y suficiente.
final class ShareTipTracker {

    private let defaults = UserDefaults.standard
    private let keyPrefix = "share_tip_shown_memorial_"

    func hasShownTip(for memorialId: UUID) -> Bool {
        defaults.bool(forKey: keyPrefix + memorialId.uuidString)
    }

    func markShown(for memorialId: UUID) {
        defaults.set(true, forKey: keyPrefix + memorialId.uuidString)
    }
}
