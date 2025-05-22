import SwiftUI
import AuthenticationServices
import Foundation

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthenticationService.self) private var authService
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                    
                    Text("Welcome to AIFoodDetective")
                        .font(.title2).bold()
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Sign in to contribute and access your personal data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
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
                            } else {
                                showError(message: "Failed to get Apple ID credentials")
                            }
                        case .failure(let error):
                            let authError = error as? ASAuthorizationError
                            let errorCode = authError?.code.rawValue ?? -1
                            print("Apple sign in failed with error code: \(errorCode)")
                            print("Error description: \(error.localizedDescription)")
                            
                            switch authError?.code {
                            case .canceled:
                                // User canceled the sign-in, no need to show error
                                break
                            case .invalidResponse:
                                showError(message: "Invalid response from Apple")
                            case .notHandled:
                                showError(message: "Sign in request not handled")
                            case .failed:
                                showError(message: "Sign in failed")
                            case .notInteractive:
                                showError(message: "Sign in request not interactive")
                            case .unknown:
                                showError(message: "An unknown error occurred")
                            default:
                                showError(message: error.localizedDescription)
                            }
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
            .alert("Sign In Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred")
            }
        }
    }
    
    private func handleAppleSignIn(_ result: ASAuthorizationAppleIDCredential) {
        isLoading = true
        
        // Handle successful Apple sign in
        authService.handleSignInWithApple(result)
        
        isLoading = false
        dismiss()
    }
    
    private func handleGoogleSignIn() {
        isLoading = true
        // Implement Google Sign In
        // You would typically use GoogleSignIn SDK here
        isLoading = false
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        isLoading = false
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationService.shared)
} 
