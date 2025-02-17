// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile
import Combine

@MainActor
class NoteCellViewModel: ObservableObject {
    @Published var title: String?
    @Published var content: String = ""
    @Published var preview: String?
    @Published var createdAt: String = ""
    @Published var updatedAt: String?
    @Published var sourceUrl: String?
    @Published var showDeleteAlert: Bool = false
}

class NoteListCell: UICollectionViewCell {
    private let viewModel = NoteCellViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private var deleteAction: (() -> Void)?

    func configure(_ presenter: NoteListPresenter?, deleteAction: @escaping () -> Void) {
        guard let presenter else { return }
        viewModel.title = presenter.title
        viewModel.content = presenter.content
        viewModel.preview = presenter.preview
        viewModel.createdAt = presenter.createdAt
        viewModel.updatedAt = presenter.updatedAt
        viewModel.sourceUrl = presenter.sourceUrl
        self.deleteAction = deleteAction
    }

    private lazy var noteView: UIView = {
        let view = UIView.embedSwiftUIView(NoteCellView(viewModel: viewModel))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(noteView)
        contentView.pinSubviewToAllEdges(noteView)

        viewModel
            .$showDeleteAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showAlert in
                if showAlert {
                    self?.deleteAction?()
                    self?.viewModel.showDeleteAlert = false
                }
            }
            .store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not welcome here")
    }
}

struct NoteCellView: View {
    @StateObject var viewModel: NoteCellViewModel

    init(viewModel: NoteCellViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        makeBody()
    }
}

// MARK: view builders
extension NoteCellView {
    func makeMarkdownString(_ markdown: String) -> AttributedString? {
        try? AttributedString(
            markdown: markdown,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace
            )
        )
    }

    func unformattedString(_ markdown: AttributedString) -> String {
        String(markdown.characters[...])
    }

    func makeBody() -> some View {
        VStack(alignment: .leading) {
            makeTextContent()
            makeBottomContent()
        }
        .padding()
    }

    func makeTextContent() -> some View {
        VStack {
            if let title = viewModel.title {
                Text(title)
                    .style(.listCellTitle)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
            }
            if let markdownContent = makeMarkdownString(viewModel.content) {
                Text(unformattedString(markdownContent))
                    .font(.body)
                    .foregroundColor(Color(.ui.black1))
                    .lineSpacing(4)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 4)
            }
        }
    }

    func makeBottomContent() -> some View {
        HStack {
            Text(viewModel.updatedAt ?? viewModel.createdAt)
                .style(.listCellDetail)
            Spacer()
            // TODO: NOTES - Add the sourceUrl case once we have it.
            if let attributedContent = makeMarkdownString(viewModel.content) {
                ShareLink(
                    item: attributedContent,
                    preview: SharePreview(viewModel.title ?? Localization.Notes.Share.defaultNoteTitle)
                ) {
                    makeShareLinkIcon()
                }
            } else {
                ShareLink(
                    item: viewModel.content,
                    preview: SharePreview(viewModel.title ?? Localization.Notes.Share.defaultNoteTitle)
                ) {
                    makeShareLinkIcon()
                }
            }
            makeOverflowMenu()
        }
    }

    func makeShareLinkIcon() -> some View {
        Image(asset: .share)
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(Color(.ui.grey8))
            .padding(.horizontal, 4)
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            Button(action: {
                Haptics.defaultTap()
                viewModel.showDeleteAlert = true
            }) {
                Label {
                    Text(Localization.Notes.Cell.OverflowMenu.delete)
                } icon: {
                    Image(asset: .delete)
                }
            }
            .accessibilityLabel("overflow-delete")
            Button(action: {
                Haptics.defaultTap()
                // TODO: NOTES - Add edit note action here
            }) {
                Label {
                    Text(Localization.Notes.Cell.OverflowMenu.edit)
                } icon: {
                    Image(asset: .delete)
                }
            }
            .accessibilityLabel("overflow-edit")
        } label: {
            Image(asset: .overflow)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(.ui.grey8))
                .padding(.horizontal, 6)
        }
        .accessibilityLabel("note-action - overflow-menu")
    }
}
