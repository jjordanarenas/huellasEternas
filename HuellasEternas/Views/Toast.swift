//
//  Toast.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 29/12/25.
//


import SwiftUI

struct Toast: Equatable {
    let message: String
    let duration: TimeInterval

    init(_ message: String, duration: TimeInterval = 2.0) {
        self.message = message
        self.duration = duration
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let toast {
                VStack {
                    Spacer()
                    Text(toast.message)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
                        withAnimation {
                            self.toast = nil
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: toast)
    }
}

extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
