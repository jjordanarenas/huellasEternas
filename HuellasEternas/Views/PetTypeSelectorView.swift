//
//  PetType.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import SwiftUI

/// Selector visual de tipo de mascota.
/// Usa iconos y texto del enum PetType.
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
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: type.systemImage)
                            .font(.system(size: 24))
                        
                        Text(type.rawValue)
                            .font(.footnote)
                            .bold()
                    }
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                selectedType == type
                                ? Color.accentColor.opacity(0.15)
                                : Color(.systemGray6)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedType == type
                                ? Color.accentColor
                                : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
