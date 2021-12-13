import Sync
import UIKit
import Textile


private extension Style {
    static let codeBlock: Self = .body.monospace
}

class CodeBlockPresenter: ArticleComponentPresenter {
    private let component: CodeBlockComponent
    
    private let readerSettings: ReaderSettings
    
    private let availableWidth: CGFloat
    
    private let dequeue: (IndexPath) -> CodeBlockComponentCell
    
    private lazy var codeBlock: NSAttributedString? = {
        NSAttributedString(string: component.text, style: .codeBlock.adjustingSize(by: readerSettings.fontSizeAdjustment))
    }()
    
    lazy var size: CGSize = {
        codeBlock.flatMap {
            var size = $0.sizeFitting()
            size.height += CodeBlockComponentCell.Constants.contentInset.top
            + CodeBlockComponentCell.Constants.contentInset.top
            return size
        } ?? .zero
    }()
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeue(indexPath)
        cell.textView.attributedText = codeBlock
        return cell
    }
    
    required init(
        component: CodeBlockComponent,
        readerSettings: ReaderSettings,
        availableWidth: CGFloat,
        dequeue: @escaping (IndexPath) -> CodeBlockComponentCell
    ) {
        self.component = component
        self.readerSettings = readerSettings
        self.availableWidth = availableWidth
        self.dequeue = dequeue
    }
}
