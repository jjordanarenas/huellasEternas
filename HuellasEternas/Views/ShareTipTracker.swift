//
//  ShareTipTracker.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import Foundation

final class ShareTipTracker {
    private let defaults: UserDefaults
    private let prefix = "share_tip_shown_memorial_"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func wasShown(for memorialId: UUID) -> Bool {
        defaults.bool(forKey: prefix + memorialId.uuidString)
    }

    func markShown(for memorialId: UUID) {
        defaults.set(true, forKey: prefix + memorialId.uuidString)
    }
}
