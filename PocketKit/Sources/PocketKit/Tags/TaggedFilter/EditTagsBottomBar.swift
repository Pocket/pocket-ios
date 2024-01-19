// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization
import Textile

struct EditTagsBottomBar: ViewModifier {
    @Binding var editMode: EditMode
    let selectedItems: Set<TagType>
    let onDelete: () -> Void
    let onRename: (String) -> Void
    @State private var showRenameAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var name = ""

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if editMode.isEditing == true {
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
                        if #available(iOS 17.0, *) {
                            Button("OK") {
                                onRename(name)
                                name = ""
                            }
                            .disabled(name.isEmpty)
                        } else {
                            Button("OK") {
                                onRename(name)
                                name = ""
                            }
                        }
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
    public func editBottomBar(editMode: Binding<EditMode>, selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) -> some View {
        self.modifier(EditTagsBottomBar(editMode: editMode, selectedItems: selectedItems, onDelete: onDelete, onRename: onRename))
    }
}
