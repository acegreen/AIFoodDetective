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
                Image(systemName: "camera.viewfinder")
                Text("Scan")
            }
            .tag(0)

            HistoryView(scannedCode: $scannedCode)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("History")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Me")
                }
                .tag(2)
        }
        .ignoresSafeArea(.keyboard)
        .toast()
        //        .enableInjection()
    }
}

#Preview {
    MainTabView()
        .environment(MessageHandler.shared)
        .environment(ProductListManager.shared)
        .environment(NetworkService.shared)
}
