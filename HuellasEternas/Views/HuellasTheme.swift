//
//  HuellasTheme.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/2/26.
//


import SwiftUI

final class HuellasTheme {
    static func apply() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(HuellasColor.background)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(HuellasColor.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(HuellasColor.textPrimary)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(HuellasColor.primaryDark)
    }
}
