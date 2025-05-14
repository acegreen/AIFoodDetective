import Foundation
import SwiftUI
import Observation

enum MessageType {
    case success
    case error
    
    var backgroundColor: Color {
        switch self {
        case .success:
            return .black.opacity(0.7)
        case .error:
            return .red.opacity(0.8)
        }
    }
}

@Observable
class MessageHandler {
    static let shared = MessageHandler()
    
    var message: String?
    var isShowing = false
    var messageType: MessageType = .success
    private var timer: Timer?
    
    private init() {} // Make init private for singleton
    
    func show(_ message: String, type: MessageType = .success, duration: TimeInterval = 2.0) {
        self.message = message
        self.messageType = type
        self.isShowing = true
        
        // Cancel any existing timer
        timer?.invalidate()
        
        // Set up new timer to hide the message
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            withAnimation {
                self?.isShowing = false
                self?.message = nil
            }
        }
    }
    
    func showError(_ message: String, duration: TimeInterval = 2.0) {
        show(message, type: .error, duration: duration)
    }
} 