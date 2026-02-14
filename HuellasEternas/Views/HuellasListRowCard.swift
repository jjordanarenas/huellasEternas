//
//  ListRowCardModifier.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/2/26.
//

import SwiftUI

struct HuellasListRowCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(HuellasColor.card)
            .listRowSeparator(.hidden)
    }
}

extension View {
    func huellasRowCard() -> some View {
        modifier(HuellasListRowCard())
    }
}
