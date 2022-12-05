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

    @State
    private var isEditing = false

    @State
    private var showDeleteAlert = false

    @State
    private var showRenameAlert: Bool = false

    @State
    private var tagsSelected = Set<String>()

    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selection) {
                    Text("not tagged")
                        .style(.tagsFilter.tag)
                        .accessibilityIdentifier("all-tags")
                        .onTapGesture {
                            didTap = true
                            viewModel.selectTag(.notTagged)
                            dismiss()
                        }.disabled(isEditing)
                    ForEach(viewModel.getAllTags(), id: \.self) { tag in
                        Text(tag)
                            .style(.tagsFilter.tag)
                            .accessibilityIdentifier("all-tags")
                            .onTapGesture {
                                didTap = true
                                viewModel.selectTag(.tag(tag))
                                dismiss()
                            }.disabled(isEditing)
                    }
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
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Tag?"),
                message: Text("Are you sure you want to delete the tags and remove it from all items?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    viewModel.delete(tags: Array(tagsSelected))
                    tagsSelected = Set<String>()
                }),
                secondaryButton: .cancel(Text("Cancel"), action: {
                })
            )
        }
        .alert(
            isPresented: $showRenameAlert,
            TextAlert(
                title: "Rename Tag",
                message: "Enter a new name for this tag"
            ) { result in
                if let text = result, let oldName = tagsSelected.first {
                    viewModel.rename(from: oldName, to: text)
                    tagsSelected = Set<String>()
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
    @ObservedObject
    var viewModel: TagsFilterViewModel

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
    @Binding var selection: Set<String>
    @Binding var tagsSelected: Set<String>
    @Binding var showRenameAlert: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        HStack {
            Button("Rename") {
                tagsSelected = selection
                showRenameAlert = true
            }
            .disabled(selection.count != 1)
            .accessibilityIdentifier("rename-button")
            Spacer()
            Button("Delete") {
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
    @ObservedObject
    var viewModel: TagsFilterViewModel
    func body(content: Content) -> some View {
        content
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

private extension Style {
    static let tagsFilter = TagsFilterStyle()
    struct TagsFilterStyle {
        let tag: Style = Style.header.sansSerif.h8.with(color: .ui.grey1)
        let sectionHeader: Style = Style.header.sansSerif.h8.with(color: .ui.grey5)
    }
}
