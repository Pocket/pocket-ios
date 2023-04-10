// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization

struct TagsFilterView: View {
    @ObservedObject var viewModel: TagsFilterViewModel

    @Environment(\.dismiss) private var dismiss

    @State var didTap = false

    @State private var selection = Set<TagType>()

    @State private var isEditing = false

    @State private var showDeleteAlert = false

    @State private var showRenameAlert: Bool = false

    @State private var tagsSelected = Set<TagType>()

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selection) {
                    let tagAction = { (tag: TagType) in
                        didTap = true
                        viewModel.selectTag(tag)
                        dismiss()
                    }
                    TagsCell(tag: .notTagged, tagAction: tagAction)
                        .disabled(isEditing)
                    TagsSectionView(
                        showRecentTags: !isEditing && !viewModel.recentTags.isEmpty,
                        recentTags: viewModel.recentTags,
                        allTags: viewModel.getAllTags(),
                        tagAction: tagAction
                    ).disabled(isEditing)
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .tagsHeaderToolBar($isEditing, viewModel: viewModel)
                Spacer()
                if isEditing {
                    EditBottomBar(selection: $selection, tagsSelected: $tagsSelected, showRenameAlert: $showRenameAlert, showDeleteAlert: $showDeleteAlert)
                }
            }
        }
        .navigationViewStyle(.stack)
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(Localization.deleteTag),
                message: Text(Localization.areYouSureYouWantToDeleteTheTagsAndRemoveItFromAllItems),
                primaryButton: .destructive(Text(Localization.delete), action: {
                    viewModel.delete(tags: Array(tagsSelected.compactMap({ $0.name })))
                    tagsSelected = Set<TagType>()
                }),
                secondaryButton: .cancel(Text(Localization.cancel), action: {
                })
            )
        }
        .alert(
            isPresented: $showRenameAlert,
            TextAlert(
                title: Localization.renameTag,
                message: Localization.enterANewNameForThisTag
            ) { result in
                if let text = result, let oldName = tagsSelected.first?.name {
                    viewModel.rename(from: oldName, to: text)
                    tagsSelected = Set<TagType>()
                }
            }
        )
        .accessibilityIdentifier("filter-tags")
        .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        .onDisappear {
            guard !didTap else { return }
            viewModel.selectAllAction()
        }
    }
}

struct EditModeView: View {
    @Environment(\.editMode) var editMode
    @Binding var isEditing: Bool
    @ObservedObject var viewModel: TagsFilterViewModel

    var body: some View {
        EditButton()
            .onChange(of: editMode?.wrappedValue.isEditing, perform: { newValue in
                isEditing = newValue ?? false
                if isEditing { viewModel.trackEditAsOverflowAnalytics() }
            })
            .accessibilityIdentifier("edit-button")
    }
}

struct EditBottomBar: View {
    @Binding var selection: Set<TagType>
    @Binding var tagsSelected: Set<TagType>
    @Binding var showRenameAlert: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        HStack {
            Button(Localization.rename) {
                tagsSelected = selection
                showRenameAlert = true
            }
            .disabled(selection.count != 1)
            .accessibilityIdentifier("rename-button")
            Spacer()
            Button(Localization.delete) {
                tagsSelected = selection
                showDeleteAlert = true
            }
            .disabled(selection.isEmpty)
            .accessibilityIdentifier("delete-button")
        }
    }
}

struct TagsHeaderToolBar: ViewModifier {
    @Binding var isEditing: Bool
    @ObservedObject var viewModel: TagsFilterViewModel
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(Localization.tags).style(.tags.sectionHeader)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(asset: .tag).foregroundColor(Color(.ui.grey5))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditModeView(isEditing: $isEditing, viewModel: viewModel)
                }
            }
    }
}

extension View {
    func tagsHeaderToolBar(_ isEditing: Binding<Bool>, viewModel: TagsFilterViewModel) -> some View {
        modifier(TagsHeaderToolBar(isEditing: isEditing, viewModel: viewModel))
    }

    public func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
        AlertWrapper(isPresented: isPresented, alert: alert, content: self)
    }
}
