import Foundation
import Sync
import UIKit


class MarkdownComponentPresenter: ArticleComponentPresenter {
    private let component: MarkdownComponent
    
    private let readerSettings: ReaderSettings
    
    private lazy var content: NSAttributedString? = {
        NSAttributedString.styled(
          markdown: component.content,
          styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
        )
    }()
    
    init(component: MarkdownComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        guard let content = content, !content.string.isEmpty else {
            return .zero
        }

        var size = content.sizeFitting(availableWidth: availableWidth)
        size.height += MarkdownComponentCell.Constants.layoutMargins.bottom

        return size
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: MarkdownComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.attributedContent = content
        return cell
    }
}
