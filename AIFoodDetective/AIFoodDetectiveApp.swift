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
    @State private var productListManager = ProductListManager.shared
    @State private var messageHandler = MessageHandler.shared
    @State private var networkService = NetworkService.shared
    
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
                .environment(messageHandler)
                .environment(productListManager)
                .environment(networkService)
                .preferredColorScheme(.light)
                .tint(.white)
        }
    }
}
