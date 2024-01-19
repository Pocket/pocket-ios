// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization
import Sync

struct TagsFilterToolBar: ViewModifier {
    @Binding var editMode: EditMode
    @ObservedObject var viewModel: TagsFilterViewModel

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(Localization.tags).style(.tags.sectionHeader)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(asset: .tag).foregroundColor(Color(.ui.grey5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .accessibilityIdentifier("edit-button")
                }
            }
            .toolbarBackground(Color(.ui.white1))
            .environment(\.editMode, $editMode)
    }
}

extension View {
    func tagsFilterToolBar(_ editMode: Binding<EditMode>, viewModel: TagsFilterViewModel) -> some View {
        modifier(TagsFilterToolBar(editMode: editMode, viewModel: viewModel))
    }
}
