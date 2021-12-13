import Foundation
import Sync
import UIKit


class MarkdownComponentPresenter: ArticleComponentPresenter {
    private let component: MarkdownComponent
    
    private let readerSettings: ReaderSettings
    
    private let availableWidth: CGFloat
    
    private let dequeue: (IndexPath) -> MarkdownComponentCell
    
    private lazy var content: NSAttributedString? = {
        NSAttributedString.styled(
          markdown: component.content,
          styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
        )
    }()
    
    lazy var size: CGSize = {
        content.flatMap {
            CGSize(width: availableWidth, height: $0.sizeFitting(availableWidth: availableWidth).height)
        } ?? .zero
    }()
    
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeue(indexPath)
        cell.attributedContent = content
        return cell
    }
    
    init(
        component: MarkdownComponent,
        readerSettings: ReaderSettings,
        availableWidth: CGFloat,
        dequeue: @escaping (IndexPath) -> MarkdownComponentCell
    ) {
            self.component = component
            self.readerSettings = readerSettings
            self.availableWidth = availableWidth
            self.dequeue = dequeue
    }
}
