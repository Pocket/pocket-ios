// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization
import Sync

struct TagsFilterView: View {
    @ObservedObject var viewModel: TagsFilterViewModel

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.editMode)
    var editMode

    @State var didTap = false
    @State private var selectedItems = Set<TagType>()
    @State private var renameTagText = ""

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor( keyPath: \Tag.name, ascending: true)
    ], animation: .default)
    private var tags: FetchedResults<Tag>

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollView in
                List(selection: $selectedItems) {
                    let tagAction = { (tag: TagType) in
                        didTap = true
                        viewModel.selectTag(tag)
                        dismiss()
                    }
                    TagsCell(tag: .notTagged, tagAction: tagAction)
                        .disabled(editMode?.wrappedValue == .active)
                    TagsSectionView(
                        recentTags: viewModel.recentTags,
                        allTags: tags.map { .tag($0.name) },
                        tagAction: tagAction
                    )
                    .disabled(editMode?.wrappedValue == .active)
                }
                .listRowInsets(EdgeInsets())
                .navigationBarTitleDisplayMode(.inline)
                .tagsHeaderToolBar(viewModel: viewModel)
                .editBottomBar(selectedItems: selectedItems) {
                    viewModel.delete(tags: Array(selectedItems.compactMap({ $0.name })))
                    selectedItems.removeAll()
                } onRename: { text in
                    viewModel.rename(from: selectedItems.first?.name, to: text)
                    selectedItems.removeAll()
                    renameTagText = text
                }
                .onChange(of: renameTagText) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            scrollView.scrollTo(renameTagText, anchor: .top)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationViewStyle(.stack)
        .accessibilityIdentifier("filter-tags")
        .onDisappear {
            guard !didTap else { return }
            viewModel.selectAllAction()
        }
    }
}

struct EditModeView: View {
    @Environment(\.editMode)
    var editMode
    @ObservedObject var viewModel: TagsFilterViewModel

    var body: some View {
        EditButton()
            .onChange(of: editMode?.wrappedValue, perform: { newValue in
                if newValue == .active {
                    viewModel.trackEditAsOverflowAnalytics()
                }
            })
            .accessibilityIdentifier("edit-button")
    }
}

struct TagsHeaderToolBar: ViewModifier {
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
                    EditModeView(viewModel: viewModel)
                }
            }
            .toolbarBackground(Color(.ui.white1))
    }
}

extension View {
    func tagsHeaderToolBar(viewModel: TagsFilterViewModel) -> some View {
        modifier(TagsHeaderToolBar(viewModel: viewModel))
    }
}
