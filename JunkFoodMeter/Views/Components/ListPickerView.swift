import SwiftUI

struct ListPickerView: View {
    @Environment(ProductListManager.self) var productListManager
    @Environment(MessageHandler.self) var messageHandler
    @Binding var isPresented: Bool
    let product: Product
    
    var body: some View {
        NavigationView {
            List {
                ForEach(productListManager.customLists) { list in
                    Button {
                        if productListManager.addToList(product, list: list) {
                            messageHandler.show("Added '\(product.productName)' to \(list.name.rawValue)")
                            isPresented = false
                        }
                    } label: {
                        HStack {
                            Text(list.name.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Add to List")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    let url = Bundle.main.url(forResource: "sampleProduct", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let welcome = try! JSONDecoder().decode(Welcome.self, from: data)
    return ListPickerView(isPresented: .constant(true), product: welcome.product)
        .environment(ProductListManager.shared)
        .environment(MessageHandler.shared)
} 
