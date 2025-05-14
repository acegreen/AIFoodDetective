//
//  NutritionScoreApp.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
import SwiftData

@main
struct NutritionScoreApp: App {
    @State private var productListManager = ProductListManager.shared
    @State private var messageHandler = MessageHandler.shared
    @State private var networkService = NetworkService.shared
    @State private var searchText = ""
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(messageHandler)
                .environment(productListManager)
                .environment(networkService)
        }
    }
}
