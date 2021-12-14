import Sync
import UIKit
import Textile


private extension Style {
    static let codeBlock: Self = .body.monospace
}

class CodeBlockPresenter: ArticleComponentPresenter {
    private let component: CodeBlockComponent
    
    private let readerSettings: ReaderSettings
    
    private lazy var codeBlock: NSAttributedString? = {
        NSAttributedString(string: component.text, style: .codeBlock.adjustingSize(by: readerSettings.fontSizeAdjustment))
    }()
    
    init(component: CodeBlockComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        codeBlock.flatMap {
            var size = $0.sizeFitting()
            size.height += CodeBlockComponentCell.Constants.contentInset.top
            + CodeBlockComponentCell.Constants.contentInset.top
            return size
        } ?? .zero
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: CodeBlockComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.textView.attributedText = codeBlock
        return cell
    }
}
