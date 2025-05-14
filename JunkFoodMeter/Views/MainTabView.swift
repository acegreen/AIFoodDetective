import SwiftUI
//import Inject

struct MainTabView: View {
    //    @ObserveInjection var inject
    @Environment(MessageHandler.self) var messageHandler
    @Environment(ProductListManager.self) var productListManager
    @Environment(NetworkService.self) var networkService
    @State private var scannedCode: String = ""
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView(selectedTab: $selectedTab, scannedCode: $scannedCode)
            .tabItem {
                Image(systemName: "barcode.viewfinder")
                Text("Scan")
            }
            .tag(0)

            ScanLogView(scannedCode: $scannedCode)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Scans")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Me")
                }
                .tag(2)
        }
        .tint(.green)
        .ignoresSafeArea(.keyboard)
        //        .enableInjection()
    }
}

#Preview {
    MainTabView()
        .environment(MessageHandler.shared)
        .environment(ProductListManager.shared)
        .environment(NetworkService.shared)
        .toast()
}
