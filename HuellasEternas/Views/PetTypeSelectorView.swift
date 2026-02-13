//
//  PetType.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//

import SwiftUI

struct PetTypeSelectorView: View {

    @Binding var selectedType: PetType

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(PetType.allCases, id: \.self) { type in
                Button {
                    selectedType = type
                    Haptics.light()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: type.systemImage)
                            .font(.system(size: 22))
                            .foregroundStyle(HuellasColor.primaryDark)

                        Text(type.rawValue)
                            .font(.footnote)
                            .bold()
                            .foregroundStyle(HuellasColor.textPrimary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                selectedType == type
                                ? HuellasColor.primary.opacity(0.18)
                                : HuellasColor.backgroundSecondary
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedType == type ? HuellasColor.primaryDark : HuellasColor.divider,
                                lineWidth: selectedType == type ? 1.5 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

