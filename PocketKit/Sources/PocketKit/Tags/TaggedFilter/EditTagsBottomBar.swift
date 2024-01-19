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
            if editMode?.wrappedValue == .active {
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
    public func editBottomBar(selectedItems: Set<TagType>, onDelete: @escaping () -> Void, onRename: @escaping (String) -> Void) -> some View {
        self.modifier(EditTagsBottomBar(selectedItems: selectedItems, onDelete: onDelete, onRename: onRename))
    }
}
