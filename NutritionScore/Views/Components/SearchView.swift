import SwiftUI
import Observation

struct SearchView: View {
    @Environment(MessageHandler.self) var messageHandler
    @Environment(NetworkService.self) var networkService
    @Binding var searchText: String
    @State private var error: Error?
    @State private var searchDebounceTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    @State private var searchMethod: SearchMethod?
    @State private var showingScanView: Bool = false

    var onProductFound: (Product, SearchMethod) -> Void

    enum SearchMethod {
        case scan
        case search
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search product or scan barcode", text: $searchText)
                        .autocorrectionDisabled()
                        .keyboardType(.numberPad)

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                            to: nil,
                                                            from: nil,
                                                            for: nil)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                Button(action: { showingScanView = true }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 20))
                        .foregroundColor(.accentColor)
                }
            }
            .frame(height: 44)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showingScanView) {
            ScanView { scannedCode in
                Task {
                    searchMethod = .scan
                    searchText = scannedCode
                    await performSearch(scannedCode)
                }
            }
        }
        .onChange(of: searchText) { newValue in
            if searchMethod != .scan {
                handleSearchTextChange(newValue)
            }
        }
    }

    private func handleSearchTextChange(_ newValue: String) {
        searchDebounceTask?.cancel()
        error = nil
        searchMethod = .search

        guard !newValue.isEmpty else {
            return
        }

        searchDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if !Task.isCancelled {
                await performSearch(newValue)
            }
        }
    }

    private func performSearch(_ query: String) async {
        isLoading = true
        defer {
            isLoading = false
            searchMethod = nil
        }

        do {
            if query.count >= 8 && query.allSatisfy({ $0.isNumber }) {
                let product = try await networkService.fetchProduct(barcode: query)
                onProductFound(product, searchMethod ?? .search)
            }
        } catch {
            messageHandler.showError(error.localizedDescription)
        }
    }
}

#Preview {
    SearchView(searchText: .constant(""), onProductFound: { _, _ in })
        .environment(MessageHandler.shared)
        .environment(NetworkService.shared)
}
