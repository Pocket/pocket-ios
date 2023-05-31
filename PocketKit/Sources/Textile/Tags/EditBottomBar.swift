// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable multiline_arguments
import SwiftUI
import Localization

public struct EditBottomBar: ViewModifier {
    let isEditing: Bool
    let selectedItems: Set<TagType>
    let onDelete: () -> Void
    let onRename: (String) -> Void
    @State var showRenameAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    @State private var name = ""

    public init(isEditing: Bool, selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) {
        self.isEditing = isEditing
        self.selectedItems = selectedItems
        self.onDelete = onDelete
        self.onRename = onRename
    }

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if isEditing {
                HStack {
                    Button(Localization.rename) {
                        showRenameAlert.toggle()
                    }
                    .alert(Localization.Tags.renameTag, isPresented: $showRenameAlert) {
                        TextField("", text: $name)
                            .autocapitalization(.none)
                        Button("OK") {
                            onRename(name)
                            name = ""
                        }
                    } message: {
                        Text(Localization.Tags.RenameTag.message)
                    }
                    .disabled(selectedItems.count != 1)
                    .accessibilityIdentifier("rename-button")

                    Spacer()

                    Button(Localization.delete) {
                        showDeleteAlert.toggle()
                    }
                    .alert(Localization.Tags.deleteTag, isPresented: $showDeleteAlert) {
                        Button(Localization.cancel, role: .cancel, action: {})
                        Button(Localization.delete, role: .destructive, action: onDelete)
                    } message: {
                        Text(Localization.Tags.DeleteTag.message)
                    }
                    .disabled(selectedItems.isEmpty)
                    .accessibilityIdentifier("delete-button")
                }
                .padding()
                .background()
            }
        }
    }
}

extension View {
    public func editBottomBar(isEditing: Bool, selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) -> some View {
        self.modifier(EditBottomBar(isEditing: isEditing, selectedItems: selectedItems, onDelete: onDelete, onRename: onRename))
    }
}

struct EditBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Edit Bottom Bar Demo")
            Spacer()
        }
        .editBottomBar(isEditing: true, selectedItems: [TagType.tag("tag 0")]) {
            print("Delete Action Taken")
        } onRename: { text in
            print("Rename Action Taken")
        }
        .padding(30)
        .previewDisplayName("Light")
        .preferredColorScheme(.light)

        VStack {
            Text("Edit Bottom Bar Demo")
            Spacer()
        }
        .editBottomBar(isEditing: true, selectedItems: [TagType.tag("tag 0")]) {
            print("Delete Action Taken")
        } onRename: { text in
            print("Rename Action Taken")
        }
        .padding(30)
        .previewDisplayName("Dark")
        .preferredColorScheme(.light)

        VStack {
            Text("Edit Bottom Bar Demo")
            Spacer()
        }
        .editBottomBar(isEditing: true, selectedItems: []) {
            print("Delete Action Taken")
        } onRename: { text in
            print("Rename Action Taken")
        }
        .padding(30)
        .previewDisplayName("Light - Disable")
        .preferredColorScheme(.light)

        VStack {
            Text("Edit Bottom Bar Demo")
            Spacer()
        }
        .editBottomBar(isEditing: true, selectedItems: []) {
            print("Delete Action Taken")
        } onRename: { text in
            print("Rename Action Taken")
        }
        .padding(30)
        .previewDisplayName("Dark - Disable")
        .preferredColorScheme(.light)
    }
}
// swiftlint:enable multiline_arguments
