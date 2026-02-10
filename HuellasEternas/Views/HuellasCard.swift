//
//  HuellasCard.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 2/2/26.
//


import SwiftUI

struct HuellasCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(HuellasColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(HuellasColor.divider, lineWidth: 1)
            )
    }
}
