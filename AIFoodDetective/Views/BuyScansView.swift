import SwiftUI
// import Inject

struct BuyScansView: View {
    // @ObserveInjection var inject

    enum Package: Identifiable, CaseIterable {
        case extra50
        case extra100
        case extra200

        var id: String { title }
        var title: String {
            switch self {
            case .extra50: return "50 Extra Scans"
            case .extra100: return "100 Extra Scans"
            case .extra200: return "200 Extra Scans"
            }
        }
        var subtitle: String {
            switch self {
            case .extra50: return "No expiration"
            case .extra100: return "No expiration"
            case .extra200: return "No expiration"
            }
        }
        var price: String {
            switch self {
            case .extra50: return "$1.95"
            case .extra100: return "$4.95"
            case .extra200: return "$9.95"
            }
        }
    }

    @State private var selectedPackage: Package = .extra50
    @State private var remainingScans = 50

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                List {
                    // Header Section
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Remaining Scans")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(remainingScans)")
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }

                    // Packages Section
                    Section(header: Text("Purchase options")) {
                        ForEach(Package.allCases) { pkg in
                            Button(action: {
                                selectedPackage = pkg
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: selectedPackage == pkg ? "largecircle.fill.circle" : "circle")
                                        .foregroundColor(selectedPackage == pkg ? .primary : .secondary)
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text(pkg.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text(pkg.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    Text(pkg.price)
                                        .font(.body.bold())
                                        .foregroundColor(.primary)
                                }
                                .padding()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .greenBackground()
                .navigationTitle("Buy Scans")
                .navigationBarTitleDisplayMode(.inline)
                .whiteNavigationTitle()


                // Buy Button
                Button(action: {
                    // Handle purchase
                }) {
                    Text("Purchase")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.systemBackground)
                        .cornerRadius(12)
                }
                .padding(24)
                .disabled(true)
            }
            // .enableInjection()
        }
    }
}
