//
//  ContentView.swift
//  JunkFoodMeter
//
//  Created by AceGreen on 2025-02-14.
//

import SwiftUI
// import Inject

struct JunkFoodMeterView: View {
    // @ObserveInjection var inject
    let product: Product

    var needleRotation: Double {
        -90.0 + (180.0 * Double(product.score))
    }

    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                // Gauge View
                    ZStack {
                        // Background semi-circle
                        Circle()
                            .trim(from: 0.5, to: 1.0)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.green, .yellow, .orange, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)

                        // Needle
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 4, height: 90)
                            .offset(y: -45)
                            .rotationEffect(.degrees(needleRotation))
                            .animation(.easeInOut, value: product.score)

                        // Center circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .shadow(radius: 2)

                        // Level indicator
                        Text("\(product.score)".uppercased())
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .shadow(radius: 2)
                            .offset(y: 40)
                    }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        // .enableInjection()
    }
}
