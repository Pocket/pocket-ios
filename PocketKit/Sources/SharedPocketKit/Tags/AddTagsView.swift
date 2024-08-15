// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import UIKit
import Combine
import Textile

public struct AddTagsView<ViewModel>: View where ViewModel: AddTagsViewModel {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.dismiss)
    private var dismiss

    @FocusState private var isTextFieldFocused: Bool

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    InputTagsView(
                        tags: viewModel.tags,
                        removeTag: viewModel.removeTag,
                        upsellView: viewModel.upsellView,
                        geometry: geometry
                    )
                    TagsListView(
                        emptyStateText: viewModel.emptyStateText,
                        recentTags: viewModel.recentTags,
                        usersTags: viewModel.otherTags,
                        tagAction: viewModel.addExistingTag
                    )
                    Spacer()
                    TextField(viewModel.placeholderText, text: Binding(get: { viewModel.newTagInput }, set: { string in viewModel.newTagInput = string.lowercased() }))
                        .limitText($viewModel.newTagInput, to: 25)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .padding(10)
                        .onSubmit {
                            guard viewModel.addNewTag(with: viewModel.newTagInput) else { return }
                            viewModel.newTagInput = ""
                        }
                        .focused($isTextFieldFocused)
                        .accessibilityIdentifier("enter-tag-name")
                }
                .navigationTitle("Add Tags")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", action: {
                            viewModel.saveTags()
                            dismiss()
                        }).accessibilityIdentifier("save-button")
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: {
                            dismiss()
                        })
                    }
                }
                .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            isTextFieldFocused = true
                        }
                    }
                .animation(.easeInOut, value: viewModel.tags)
            }
        }
        .accessibilityIdentifier("add-tags")
    }
}

extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self.onChange(of: text.wrappedValue) { _ in
            text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
        }
    }
}
