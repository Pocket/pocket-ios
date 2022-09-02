import Sync
import UIKit
import Textile

private extension Style {
    static let blockquote: Self = .body.serif
        .with(slant: .italic)
        .with(size: 23)
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.1))
        }
}

class BlockquoteComponentPresenter: ArticleComponentPresenter {
    private let component: BlockquoteComponent

    private let readerSettings: ReaderSettings

    private var cachedAttributedBlockquote: NSAttributedString?
    private var attributedBlockquote: NSAttributedString? {
        cachedAttributedBlockquote ?? loadAttributedBlockquote()
    }

    init(component: BlockquoteComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        attributedBlockquote.flatMap {
            var size = $0.sizeFitting(
                availableWidth: availableWidth
                - BlockquoteComponentCell.Constants.dividerWidth
                - BlockquoteComponentCell.Constants.stackSpacing
            )

            size.height += BlockquoteComponentCell.Constants.layoutMargins.bottom

            return size
        } ?? .zero
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: BlockquoteComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.attributedBlockquote = attributedBlockquote
        return cell
    }

    func clearCache() {
        cachedAttributedBlockquote = nil
    }

    private func loadAttributedBlockquote() -> NSAttributedString? {
        cachedAttributedBlockquote = NSAttributedString.styled(
            markdown: component.content,
            styler: NSAttributedString.defaultStyler(
                with: readerSettings,
                bodyStyle: .blockquote.modified(by: readerSettings)
            )
        )

        return cachedAttributedBlockquote
    }
}
