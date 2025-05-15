import SwiftUI

struct CreateListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var listName: String
    let isEditing: Bool
    let onSave: (String) -> Void
    
    init(initialName: String = "", isEditing: Bool = false, onSave: @escaping (String) -> Void) {
        _listName = State(initialValue: initialName)
        self.isEditing = isEditing
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("List name", text: $listName)
            }
            .navigationTitle(isEditing ? "Edit List" : "Create New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        onSave(listName)
                        dismiss()
                    }
                    .disabled(listName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}