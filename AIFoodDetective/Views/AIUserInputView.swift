import SwiftUI

struct AIUserInputView: View {
//    @ObserveInjection var inject
    @Binding var isPresented: Bool
    @Binding var userInput: String
    let onConfirm: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Additional Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Please provide any additional details about your meal that might not be visible in the image.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                
                TextField("e.g., coffee with milk, tea with sugar", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
                Button("Analyze") {
                    onConfirm(userInput)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .font(.headline)
                .padding(12)
                .tint(.white)
                .foregroundStyle(.green)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .onAppear {
            userInput = ""
        }
        .presentationBackground(Color.systemBackground)
        .presentationDetents([.medium])
//        .enableInjection()
    }
}
