import SwiftUI
import AuthenticationServices
import Foundation

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                    
                    Text("Welcome to Nutrition Score")
                        .font(.title2)
                        .bold()
                    
                    Text("Sign in to contribute and access your personal data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(48)
                
                Spacer()
                
                // Sign in buttons
                VStack(spacing: 16) {
                    // Sign in with Apple
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                handleAppleSignIn(appleIDCredential)
                            }
                        case .failure(let error):
                            print("Apple sign in failed: \(error.localizedDescription)")
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(8)
                    
                    // Sign in with Google
                    Button {
                        handleGoogleSignIn()
                    } label: {
                        HStack {
                            Image("google_logo") // Add this image to your assets
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text("Sign in with Google")
                                .font(.body.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            #endif
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func handleAppleSignIn(_ result: ASAuthorizationAppleIDCredential) {
        isLoading = true
        
        // Handle successful Apple sign in
        // You would typically send this to your backend
        print("Successfully signed in with Apple: \(result.user)")
        
        isLoading = false
    }
    
    private func handleGoogleSignIn() {
        isLoading = true
        // Implement Google Sign In
        // You would typically use GoogleSignIn SDK here
        isLoading = false
    }
}

#Preview {
    SignInView()
} 
