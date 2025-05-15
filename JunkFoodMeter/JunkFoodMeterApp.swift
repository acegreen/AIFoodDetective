//
//  NutritionScoreApp.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
import SwiftData
import UIKit

struct WhiteNavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemGreen), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func whiteNavigationTitle() -> some View {
        modifier(WhiteNavigationTitleModifier())
    }
}

@main
struct JunkFoodMeterApp: App {
    @State private var productListManager = ProductListManager.shared
    @State private var messageHandler = MessageHandler.shared
    @State private var networkService = NetworkService.shared
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color.systemBackground)
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(messageHandler)
                .environment(productListManager)
                .environment(networkService)
                .preferredColorScheme(.light)
                .tint(.white)
        }
    }
}
