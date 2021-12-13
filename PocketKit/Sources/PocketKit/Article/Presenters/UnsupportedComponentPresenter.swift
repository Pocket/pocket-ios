import Sync
import UIKit


class UnsupportedComponentPresenter: ArticleComponentPresenter {
    private let availableWidth: CGFloat
    private let dequeue: (IndexPath) -> UnsupportedComponentCell
    
    lazy var size: CGSize = {
        CGSize(width: availableWidth, height: 86)
    }()
    
    init(availableWidth: CGFloat, dequeue: @escaping (IndexPath) -> UnsupportedComponentCell) {
        self.availableWidth = availableWidth
        self.dequeue = dequeue
    }
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeue(indexPath)
        return cell
    }
}
