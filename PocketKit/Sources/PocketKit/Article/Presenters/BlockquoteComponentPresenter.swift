import Sync
import UIKit


class BlockquoteComponentPresenter: ArticleComponentPresenter {
    private let component: BlockquoteComponent
    
    private let readerSettings: ReaderSettings
    
    private let availableWidth: CGFloat
    
    private let dequeue: (IndexPath) -> BlockquoteComponentCell
    
    private lazy var attributedBlockquote: NSAttributedString? = {
        NSAttributedString.styled(
            markdown: component.content,
            styler: NSAttributedString.defaultStyler(with: readerSettings)
        )
    }()
    
    lazy var size: CGSize = {
        attributedBlockquote.flatMap {
            let availableWidth = availableWidth
            - BlockquoteComponentCell.Constants.dividerWidth
            - BlockquoteComponentCell.Constants.stackSpacing
            return $0.sizeFitting(availableWidth: availableWidth)
        } ?? .zero
    }()
    
    init(
        component: BlockquoteComponent,
        readerSettings: ReaderSettings,
        availableWidth: CGFloat,
        dequeue: @escaping (IndexPath) -> BlockquoteComponentCell
    ) {
            self.component = component
            self.readerSettings = readerSettings
            self.availableWidth = availableWidth
            self.dequeue = dequeue
    }
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeue(indexPath)
        cell.attributedBlockquote = attributedBlockquote
        return cell
    }
}
