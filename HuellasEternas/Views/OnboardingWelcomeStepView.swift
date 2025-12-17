//
//  OnboardingWelcomeStepView.swift
//  HuellasEternas
//
//  Created by Jorge Jordán on 16/12/25.
//


import SwiftUI

struct OnboardingWelcomeStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer()
            
            Image(systemName: "pawprint.circle.fill")
                .font(.system(size: 64))
            
            Text("Un lugar para recordar")
                .font(.largeTitle)
                .bold()
            
            Text("Crea un memorial para tu mascota, recibe apoyo cuando lo necesites y deja que amigos y familia también puedan rendir homenaje.")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}
