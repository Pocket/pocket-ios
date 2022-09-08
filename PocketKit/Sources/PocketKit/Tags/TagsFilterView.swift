// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct TagsFilterView: View {
    @ObservedObject
    var viewModel: TagsFilterViewModel

    @Environment(\.dismiss)
    private var dismiss

    @State
    var didTap = false

    @State
    private var selection = Set<String>()

    var body: some View {
        NavigationView {
            List(viewModel.getAllTags(), id: \.self, selection: $selection) { tag in
                Text(tag)
                    .style(.tagsFilter.tag)
                    .accessibilityIdentifier("all-tags")
                    .onTapGesture {
                        didTap = true
                        let isNotTagged = tag == TagsFilterViewModel.SelectedTag.notTagged.name
                        let selectedTag: TagsFilterViewModel.SelectedTag = isNotTagged ? .notTagged : .tag(tag)
                        viewModel.selectTag(selectedTag)
                        dismiss()
                    }
            }
            .listStyle(.plain)
            .accessibilityIdentifier("filter-tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Tags").style(.tagsFilter.sectionHeader)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(asset: .tag).foregroundColor(Color(.ui.grey5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        .onDisappear {
            guard !didTap else { return }
            viewModel.selectAllAction()
        }
    }
}

struct ListHeader: View {
    var body: some View {
        HStack {
            Text("Tags").style(.tagsFilter.sectionHeader)
            Spacer()
            Button("Edit", action: {
                // TODO: Edit Screen
            }).accessibilityIdentifier("edit-button")
        }

    }
}

private extension Style {
    static let tagsFilter = TagsFilterStyle()
    struct TagsFilterStyle {
        let tag: Style = Style.header.sansSerif.h8.with(color: .ui.grey1)
        let sectionHeader: Style = Style.header.sansSerif.h8.with(color: .ui.grey5)
    }
}
