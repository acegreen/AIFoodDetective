import Foundation
import AuthenticationServices
import Observation

@Observable
class AuthenticationService {
    static let shared = AuthenticationService()
    
    private(set) var isSignedIn = false
    private(set) var userIdentifier: String?
    private(set) var userEmail: String?
    private(set) var userName: String?
    
    private init() {
        // Check for existing credentials
        checkExistingCredentials()
    }
    
    private func checkExistingCredentials() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: UserDefaults.standard.string(forKey: "userIdentifier") ?? "") { [weak self] state, error in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self?.isSignedIn = true
                    self?.userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier")
                    self?.userEmail = UserDefaults.standard.string(forKey: "userEmail")
                    self?.userName = UserDefaults.standard.string(forKey: "userName")
                case .revoked, .notFound:
                    self?.signOut()
                default:
                    break
                }
            }
        }
    }
    
    func handleSignInWithApple(_ credential: ASAuthorizationAppleIDCredential) {
        // Save user identifier
        let userIdentifier = credential.user
        UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
        self.userIdentifier = userIdentifier
        
        // Save email if available
        if let email = credential.email {
            UserDefaults.standard.set(email, forKey: "userEmail")
            self.userEmail = email
        }
        
        // Save name if available
        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            UserDefaults.standard.set(name, forKey: "userName")
            self.userName = name
        }
        
        isSignedIn = true
    }
    
    func signOut() {
        isSignedIn = false
        userIdentifier = nil
        userEmail = nil
        userName = nil
        
        // Clear stored credentials
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userName")
    }
} 