import SwiftUI
//import Inject

struct SettingsView: View {
    //    @ObserveInjection var inject
    @State private var isSignedIn = false
    @State private var showingSignIn = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Welcome Card
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
                .padding()
                .background(.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                // Food Preferences Card
                NavigationLink(destination: Text("Food Preferences")) {
                    HStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Food Preferences")
                                .font(.headline)
                                .foregroundColor(.secondary)
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
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }

                // Prices Card
                NavigationLink(destination: Text("Prices")) {
                    HStack(spacing: 16) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 24)

                        Text("Prices")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.white)
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
                            .foregroundColor(.primary)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Donate")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Donate to JunkFoodMeter")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.up.forward.square")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }

                // App Settings Card
                NavigationLink(destination: Text("App Settings")) {
                    HStack(spacing: 16) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("App Settings")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Dark mode, Languages...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding()
        }
        .background(Color.systemBackground)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .whiteNavigationTitle()
        .sheet(isPresented: $showingSignIn) {
            SignInView()
        }
        //        .enableInjection()
    }
}

#Preview {
    SettingsView()
}
