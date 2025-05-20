import SwiftUI
// import Inject

struct BuyScansView: View {
    // @ObserveInjection var inject

    enum Package: Identifiable, CaseIterable {
        case extra200
        case extra500
        case extra1000

        var id: String { title }
        var title: String {
            switch self {
            case .extra200: return "200 Extra Scans"
            case .extra500: return "500 Extra Scans"
            case .extra1000: return "1000 Extra Scans"
            }
        }
        var subtitle: String {
            switch self {
            case .extra200: return "No expiration"
            case .extra500: return "No expiration"
            case .extra1000: return "No expiration"
            }
        }
        var price: String {
            switch self {
            case .extra200: return "$1.95"
            case .extra500: return "$4.95"
            case .extra1000: return "$9.95"
            }
        }
    }

    @State private var selectedPackage: Package = .extra200
    @State private var remainingScans = 200

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Remaining Scans")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(remainingScans)")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)

                // Packages List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Purchase options")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))

                    ForEach(Package.allCases) { pkg in
                        Button(action: {
                            selectedPackage = pkg
                        }) {
                            HStack {
                                Image(systemName: selectedPackage == pkg ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(selectedPackage == pkg ? .white : .secondary)
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text(pkg.title)
                                        .font(.body)
                                        .foregroundColor(.white)
                                    Text(pkg.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Text(pkg.price)
                                    .font(.body.bold())
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Spacer()

                Button(action: {
                    // Handle purchase
                }) {
                    Text("Purchase")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(true)

                Spacer()
            }
            .padding()
            .frame(maxHeight: .infinity)
            .greenBackground()
        }
        // .enableInjection()
    }
}
