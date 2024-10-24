// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization
import Textile

struct EditTagsBottomBar: ViewModifier {
    @Binding var editMode: EditMode
    @Binding var showRenameAlert: Bool
    let selectedItems: Set<TagType>
    let onDelete: () -> Void
    let onRename: (String) -> Void
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
                        // Apparently, iOS17+ does not play well with the .disabled() method
                        // so we just keep the button as it is for now on it.
                        if #available(iOS 18.0, *) {
                            Button(Localization.rename, role: .destructive, action: {
                                onRename(name)
                                name = ""
                            })
                            .disabled(name.isEmpty)
                        } else {
                            Button(Localization.rename, role: .destructive, action: {
                                onRename(name)
                                name = ""
                            })
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
                        Button(Localization.delete, role: .destructive, action: {
                            onDelete()
                        })
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
    public func editBottomBar(editMode: Binding<EditMode>, showRenameAlert: Binding<Bool>, selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) -> some View {
        self.modifier(EditTagsBottomBar(editMode: editMode, showRenameAlert: showRenameAlert, selectedItems: selectedItems, onDelete: onDelete, onRename: onRename))
    }
}
