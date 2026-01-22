//
//  ShareComposer.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 29/12/25.
//


import Foundation

struct ShareComposer {

    static func shareText(memorialName: String, shareToken: String) -> String {
        if FeatureFlags.hasCustomDomain {
            let url = "https://huellas.app/m/\(shareToken)"
            return """
            He creado este memorial para \(memorialName).
            Puedes verlo y encender una vela aquí: \(url)
            """
        } else {
            return """
            He creado este memorial para \(memorialName).

            Para unirte:
            1) Abre la app Huellas Eternas
            2) Ve a “Unirme”
            3) Pega este código: \(shareToken)
            """
        }
    }

    static func shareURLIfAvailable(shareToken: String) -> URL? {
        guard FeatureFlags.hasCustomDomain else { return nil }
        return URL(string: "https://huellas.app/m/\(shareToken)")
    }

    static func memorialShareText(memorialName: String, shareToken: String) -> String {
        """
        He creado este memorial para \(memorialName).
        Para verlo y encender una vela en su honor, abre la app “HuellasEternas” y pega este código en “Unirme a un memorial”:

        \(shareToken)
        """
    }
}
