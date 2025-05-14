import SwiftUI
//import Inject

struct ProfileView: View {
//    @ObserveInjection var inject
    @State private var isSignedIn = false
    @State private var showingSignIn = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Welcome Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Welcome!")
                            .font(.title)
                            .bold()
                        
                        Text("Sign-in or sign-up to join our community")
                            .font(.body)
                        
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
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Food Preferences Card
                    NavigationLink(destination: Text("Food Preferences")) {
                        HStack(spacing: 16) {
                            Image(systemName: "fork.knife")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Food Preferences")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                Text("Choose what information about food matters most to you.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // Prices Card
                    NavigationLink(destination: Text("Prices")) {
                        HStack(spacing: 16) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Prices")
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // Donate Card
                    Button(action: {
                        // Handle donate action
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: "heart.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Donate")
                                    .font(.headline)
                                Text("Donate to Nutrition Score")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.forward.square")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // App Settings Card
                    NavigationLink(destination: Text("App Settings")) {
                        HStack(spacing: 16) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("App Settings")
                                    .font(.headline)
                                Text("Dark mode, Languages...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingSignIn) {
                SignInView()
            }
        }
//        .enableInjection()
    }
}

#Preview {
    ProfileView()
} 
