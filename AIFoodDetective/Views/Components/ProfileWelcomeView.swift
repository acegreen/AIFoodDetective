//
//  ProfileWelcomeView.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-05-20.
//

import SwiftUI
import Observation

struct ProfileWelcomeView: View {
    @Binding var showingSignIn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome!")
                .font(.title).bold()
                .foregroundColor(.primary)

            Text("Sign-in or sign-up to join our community")
                .font(.body)
                .foregroundColor(.secondary)

            Button(action: {
                showingSignIn = true
            }) {
                Text("Sign in")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    ProfileWelcomeView(showingSignIn: .constant(false))
}
