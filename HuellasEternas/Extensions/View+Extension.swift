//
//  View+Extension.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 10/2/26.
//

import SwiftUI

extension View {
    func huellasBackground() -> some View {
        self
            .background(HuellasColor.background)
    }

    func cardStyle() -> some View {
        self
            .padding()
            .background(HuellasColor.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(HuellasColor.divider, lineWidth: 1)
            )
    }
}
