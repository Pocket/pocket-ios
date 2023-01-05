import SwiftUI
import UIKit
import Combine

enum Constants {
    static let tagsHorizontalSpacing: CGFloat = 6
    static let tagPadding: CGFloat = 4
}

public struct AddTagsView<ViewModel>: View where ViewModel: AddTagsViewModel {
    @ObservedObject
    var viewModel: ViewModel

    @State
    private var newTag: String = ""

    @Environment(\.dismiss)
    private var dismiss

    @FocusState
    private var isTextFieldFocused: Bool

    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    InputTagsView(viewModel: viewModel, geometry: geometry)
                    OtherTagsView(viewModel: viewModel)
                    Spacer()
                    TextField(viewModel.placeholderText, text: $newTag)
                        .limitText($newTag, to: 25)
                        .textFieldStyle(.roundedBorder)
                        .padding(10)
                        .onSubmit {
                            guard viewModel.addTag(with: newTag) else { return }
                            newTag = ""
                        }
                        .focused($isTextFieldFocused)
                        .accessibilityIdentifier("enter-tag-name")
                }
                .navigationTitle("Add Tags")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", action: {
                            viewModel.addTags()
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

    struct InputTagsView: View {
        @ObservedObject
        var viewModel: ViewModel

        @Namespace
        var animation

        let geometry: GeometryProxy

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(getRows(screenWidth: geometry.size.width), id: \.self) { rows in
                        HStack(spacing: Constants.tagsHorizontalSpacing) {
                            ForEach(rows, id: \.self) { row in
                                RowView(tag: row)
                            }
                        }
                    }
                }.padding()
                Divider()
                    .frame(height: 10)
                    .overlay(Color(.ui.grey7))
            }
        }

        func RowView(tag: String) -> some View {
            Text(tag)
                .style(.addTags.tag)
                .padding(Constants.tagPadding)
                .background(Rectangle().fill(Color(.ui.grey6)))
                .cornerRadius(4)
                .lineLimit(1)
                .onTapGesture {
                    viewModel.removeTag(with: tag)
                }
                .accessibilityIdentifier("tag")
                .matchedGeometryEffect(id: tag, in: animation)
        }

        func getRows(screenWidth: CGFloat) -> [[String]] {
            var rows: [[String]] = []
            var currentRow: [String] = []

            var totalWidth: CGFloat = 0
            let safeWidth: CGFloat = screenWidth
            let padding: CGFloat = Constants.tagPadding * 2 + Constants.tagsHorizontalSpacing * 2

            viewModel.tags.forEach { tag in
                let attributes = Style.addTags.tag.textAttributes
                let tagWidth: CGFloat = tag.size(withAttributes: attributes).width + padding

                totalWidth += tagWidth

                if totalWidth > safeWidth {
                    totalWidth = (!currentRow.isEmpty || rows.isEmpty ? tagWidth : 0)
                    rows.append(currentRow)
                    currentRow.removeAll()
                    currentRow.append(tag)
                } else {
                    currentRow.append(tag)
                }
            }

            if !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow.removeAll()
            }
            return rows
        }
    }

    struct OtherTagsView: View {
        @ObservedObject
        var viewModel: ViewModel

        var body: some View {
            if let otherTags = viewModel.allOtherTags(), !otherTags.isEmpty {
                List {
                    Section(header: Text("All Tags").style(.addTags.sectionHeader)) {
                        ForEach(otherTags, id: \.self) { tag in
                            HStack {
                                Text(tag).style(.addTags.allTags)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                _ = viewModel.addTag(with: tag)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .accessibilityIdentifier("all-tags")
            } else {
                // TODO: Empty State View (IN-779)
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Text(viewModel.emptyStateText)
                        .style(.addTags.emptyStateText)
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

private extension Style {
    static let addTags = AddTagsStyle()
    struct AddTagsStyle {
        let emptyStateText: Style = Style.header.sansSerif.p2.with { $0.with(alignment: .center).with(lineSpacing: 6) }
        let sectionHeader: Style = Style.header.sansSerif.h8.with(color: .ui.grey4)
        let tag: Style = Style.header.sansSerif.h8.with(color: .ui.grey4)
        let allTags: Style = Style.header.sansSerif.h8.with(color: .ui.grey1)
    }
}

extension View {
    func limitText(_ text: Binding<String>, to characterLimit: Int) -> some View {
        self.onChange(of: text.wrappedValue) { _ in
            text.wrappedValue = String(text.wrappedValue.prefix(characterLimit))
        }
    }
}
