import Sync
import UIKit


class BlockquoteComponentPresenter: ArticleComponentPresenter {
    private let component: BlockquoteComponent
    
    private let readerSettings: ReaderSettings
    
    private lazy var attributedBlockquote: NSAttributedString? = {
        NSAttributedString.styled(
            markdown: component.content,
            styler: NSAttributedString.defaultStyler(with: readerSettings)
        )
    }()
    
    init(component: BlockquoteComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        attributedBlockquote.flatMap {
            let availableWidth = availableWidth
            - BlockquoteComponentCell.Constants.dividerWidth
            - BlockquoteComponentCell.Constants.stackSpacing
            return $0.sizeFitting(availableWidth: availableWidth)
        } ?? .zero
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: BlockquoteComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.attributedBlockquote = attributedBlockquote
        return cell
    }
}
