// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization
import Textile

struct EditTagsBottomBar: ViewModifier {
    @Environment(\.editMode)
    var editMode
    let selectedItems: Set<TagType>
    let onDelete: () -> Void
    let onRename: (String) -> Void
    @State var showRenameAlert: Bool = false
    @State var showDeleteAlert: Bool = false
    @State private var name = ""

    public init(selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) {
        self.selectedItems = selectedItems
        self.onDelete = onDelete
        self.onRename = onRename
    }

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if editMode?.wrappedValue.isEditing == true {
                HStack {
                    Button(Localization.rename) {
                        showRenameAlert.toggle()
                    }
                    .accessibilityIdentifier("rename-button")
                    .disabled(selectedItems.count != 1)
                    .alert(Localization.Tags.renameTag, isPresented: $showRenameAlert) {
                        TextField(Localization.Tags.RenameTag.prompt, text: $name)
                            .autocapitalization(.none)
                        Button(Localization.cancel, role: .cancel, action: {})
                        Button("OK") {
                            onRename(name)
                            name = ""
                        }
                        .disabled(name.isEmpty)
                    } message: {
                        Text(Localization.Tags.RenameTag.message)
                    }

                    Spacer()

                    Button(Localization.delete) {
                        showDeleteAlert.toggle()
                    }
                    .accessibilityIdentifier("delete-button")
                    .disabled(selectedItems.isEmpty)
                    .alert(Localization.Tags.deleteTag, isPresented: $showDeleteAlert) {
                        Button(Localization.cancel, role: .cancel, action: {})
                        Button(Localization.delete, role: .destructive, action: onDelete)
                    } message: {
                        Text(Localization.Tags.DeleteTag.message)
                    }
                }
                .padding()
                .background()
            }
        }
    }
}

extension View {
    public func editBottomBar(selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) -> some View {
        self.modifier(EditTagsBottomBar(selectedItems: selectedItems, onDelete: onDelete, onRename: onRename))
    }
}
