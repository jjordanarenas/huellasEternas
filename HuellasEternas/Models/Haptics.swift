//
//  Haptics.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 29/12/25.
//


import UIKit

enum Haptics {
    /// Vibración ligera tipo “tap” (agradable, no molesta)
    static func light() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred()
    }

    /// Para errores (más “notable” que light)
    static func error() {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.error)
    }

    /// Para éxito (cuando se une bien)
    static func success() {
        let gen = UINotificationFeedbackGenerator()
        gen.prepare()
        gen.notificationOccurred(.success)
    }
}
