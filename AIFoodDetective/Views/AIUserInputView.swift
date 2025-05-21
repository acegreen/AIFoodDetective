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
                
                Text("Please provide any additional details about your meal that might not be visible in the image.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("e.g., coffee with milk, tea with sugar", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button("Confirm") {
                    onConfirm(userInput)
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
        .presentationBackground(Color.systemBackground)
        .presentationDetents([.medium])
//        .enableInjection()
    }
}