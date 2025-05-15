import SwiftUI
import Observation
import UIKit


struct AIMealPreviewCard: View {
    @Binding var isPresented: Bool
    let analysisResult: String
    let capturedImage: UIImage
    @Environment(ProductListManager.self) var productListManager
    @Environment(MessageHandler.self) var messageHandler
    @State private var showingListPicker = false
    @State private var product: Product?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray3))
                        .font(.title3)
                }
            }
            
            // Captured Image
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .cornerRadius(8)
            
            // Analysis Result
            ScrollView {
                Text(analysisResult)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
            }
            .frame(maxHeight: 200)
            
            // Add to List Button
            HStack(spacing: 12) {
                Button {
                    showingListPicker = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to List")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.headline)
                }
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 0)
        .padding(.horizontal, 40)
        .sheet(isPresented: $showingListPicker) {
            if let product = product {
                ListPickerView(isPresented: $showingListPicker, product: product)
            }
        }
        .toast()
    }
}

#Preview {
    AIMealPreviewCard(
        isPresented: .constant(true),
        analysisResult: "This meal contains:\n- Grilled chicken breast\n- Steamed vegetables\n- Brown rice\n\nNutritional highlights:\n- High in protein\n- Low in fat\n- Good source of fiber",
        capturedImage: UIImage(systemName: "photo")!
    )
    .environment(ProductListManager.shared)
    .environment(MessageHandler.shared)
} 
