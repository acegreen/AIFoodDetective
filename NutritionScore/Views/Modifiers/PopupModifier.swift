import SwiftUI

struct PopupModifier<PopupContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let popupContent: PopupContent
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> PopupContent) {
        self._isPresented = isPresented
        self.popupContent = content()
    }
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    Color.black
                        .opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    
                    popupContent
                        .transition(.scale.combined(with: .opacity))
                }
            }
    }
}

extension View {
    func popup<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(PopupModifier(isPresented: isPresented, content: content))
    }
} 