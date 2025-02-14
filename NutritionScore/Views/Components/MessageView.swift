import SwiftUI
import Observation

struct MessageView: View {
    @Environment(MessageHandler.self) var messageHandler
    
    var body: some View {
        if messageHandler.isShowing, let message = messageHandler.message {
            VStack {
                Spacer()
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(messageHandler.messageType.backgroundColor)
                    )
                    .padding(.bottom, 20)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut, value: messageHandler.isShowing)
            .zIndex(1) // Ensure it appears above other content
        }
    }
}

struct MessageToast: ViewModifier {
    @Environment(MessageHandler.self) var messageHandler
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if messageHandler.isShowing, let message = messageHandler.message {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(messageHandler.messageType.backgroundColor)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: messageHandler.isShowing)
                }
            }
    }
}

extension View {
    func toast() -> some View {
        modifier(MessageToast())
    }
}
#Preview {
    MessageView()
        .environment(MessageHandler.shared)
} 
