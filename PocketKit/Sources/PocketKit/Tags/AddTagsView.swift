import SwiftUI
import UIKit
import Textile

struct AddTagsView: View {
    @ObservedObject
    var viewModel: AddTagsViewModel
    
    @State
    private var newTag: String = ""
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Namespace var animation
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(alignment: .leading, spacing: 0) {
                    Divider()
                    VStack(spacing: 6) {
                        ForEach(getRows(screenWidth: geometry.size.width), id: \.self) { rows in
                            HStack(spacing: 6) {
                                ForEach(rows, id: \.self) { row in
                                    RowView(tag: row)
                                }
                            }
                        }
                    }.padding()
                    Divider()
                    Spacer()
                    TextField(viewModel.placeholderText, text: $newTag)
                        .textFieldStyle(.roundedBorder)
                        .padding(10)
                        .onSubmit {
                            guard viewModel.addTag(with: newTag) else { return }
                            newTag = ""
                        }.accessibilityIdentifier("enter-tag-name")
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
                .animation(.easeInOut, value: viewModel.tags)
            }
        }.accessibilityIdentifier("add-tags")
    }
    
    func RowView(tag: String) -> some View {
        Text(tag)
            .style(.tag)
            .padding(4)
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
        let padding: CGFloat = 20  // 4 horizontal padding in viewbuilder and 6 padding in hstack
    
        viewModel.tags.forEach { tag in
            let attributes = Style.tag.textAttributes
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

private extension Style {
    static let tag: Self = .header.sansSerif.h8.with(color: .ui.grey3)
}
