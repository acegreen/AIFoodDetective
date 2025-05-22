import SwiftUI
//import Inject

struct SettingsView: View {
//    @ObserveInjection var inject
    
    var body: some View {
        NavigationStack {
            List {
                // Food Preferences Section
                Section(header: Text("Food Preferences")) {
                    NavigationLink(destination: Text("Food Preferences")) {
                        HStack(spacing: 16) {
                            Image(systemName: "fork.knife")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text("Food Preferences")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }

                // General Section
                Section(header: Text("General")) {
                    NavigationLink(destination: Text("Units & Conventions")) {
                        HStack(spacing: 16) {
                            Image(systemName: "ruler")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text("Units & Conventions")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                    NavigationLink(destination: Text("Display & Accessibility")) {
                        HStack(spacing: 16) {
                            Image(systemName: "figure.stand")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text("Display & Accessibility")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }

                // Notifications Section
                Section(header: Text("Notifications")) {
                    NavigationLink(destination: Text("Reminders & Notifications")) {
                        HStack(spacing: 16) {
                            Image(systemName: "bell.badge.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text("Reminders & Notifications")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }

                // Support Section
                Section(header: Text("Support")) {
                    NavigationLink(destination: Text("Advice & Tips")) {
                        HStack(spacing: 16) {
                            Image(systemName: "questionmark.bubble.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text("Advice & Tips")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }

                // Account Section
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Account & Privacy")) {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: 24)
                            Text("Account & Privacy")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                    NavigationLink(destination: Text("Manage Subscription")) {
                        HStack(spacing: 16) {
                            Image(systemName: "star.circle.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            Text("Manage Subscription")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .greenBackground()
            .navigationTitle("App Settings")
            .navigationBarTitleDisplayMode(.inline)
            .whiteNavigationTitle()
//            .enableInjection()
        }
    }
}

#Preview {
    SettingsView()
} 
