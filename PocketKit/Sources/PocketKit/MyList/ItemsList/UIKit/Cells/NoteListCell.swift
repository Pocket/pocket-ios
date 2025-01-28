// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

@MainActor
class NoteCellViewModel: ObservableObject {
    @Published var title: String?
    @Published var content: String = ""
    @Published var createdAt: String = ""
    @Published var updatedAt: String?
    @Published var sourceUrl: String?
}

class NoteListCell: UICollectionViewCell {
    private let viewModel = NoteCellViewModel()

    func configure(_ presenter: NoteListPresenter?) {
        guard let presenter else { return }
        viewModel.title = presenter.title
        viewModel.content = presenter.content
        viewModel.createdAt = presenter.createdAt
        viewModel.updatedAt = presenter.updatedAt
        viewModel.sourceUrl = presenter.sourceUrl
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

    @State private var showDeleteAlert: Bool = false

    var body: some View {
        makeBody()
            .alert(Localization.Notes.Cell.DeleteAlert.message, isPresented: $showDeleteAlert) {
                Button(Localization.Notes.Cell.DeleteAlert.noButton, role: .cancel) { }
                Button(Localization.Notes.Cell.DeleteAlert.yesButton, role: .destructive) {
                    withAnimation {
                        // TODO: NOTES - Add code to delete a note from Core Data
                    }
                }
            }
    }
}

// MARK: view builders
extension NoteCellView {
    func makeBody() -> some View {
        VStack(alignment: .leading) {
            makeTextContent()
            makeBottomContent()
        }
    }

    func makeTextContent() -> some View {
        VStack {
            Text(viewModel.title ?? "")
                .font(.headline)
            Text(viewModel.content)
                .font(.body)
        }
    }

    func makeBottomContent() -> some View {
        HStack {
            Text(viewModel.updatedAt ?? viewModel.createdAt)
            Spacer()
            ShareLink(item: viewModel.content) {
                Image(asset: .share)
            }
            makeOverflowMenu()
        }
    }

    /// Overflow menu
    func makeOverflowMenu() -> some View {
        Menu {
            Button(action: {
                Haptics.defaultTap()
                showDeleteAlert = true
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
                .homeOverflowMenyStyle()
        }
        .accessibilityLabel("note-action - overflow-menu")
    }
}
