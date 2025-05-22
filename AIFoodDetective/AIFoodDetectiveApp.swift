//
//  NutritionScoreApp.swift
//  AIFoodDetective
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct AIFoodDetectiveApp: App {
    @State private var networkService = NetworkService.shared
    @State private var authService = AuthenticationService.shared
    @State private var productListManager = ProductListManager.shared
    @State private var messageHandler = MessageHandler.shared
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(.systemBackground)
        UITabBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(.systemBackground)
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(networkService)
                .environment(authService)
                .environment(productListManager)
                .environment(messageHandler)
                .preferredColorScheme(.light)
                .tint(.white)
        }
    }
}
