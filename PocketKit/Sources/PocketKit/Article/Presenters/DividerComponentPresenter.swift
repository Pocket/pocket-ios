import Sync
import UIKit


class DividerComponentPresenter: ArticleComponentPresenter {
    private let component: DividerComponent
    
    private let availableWidth: CGFloat
    
    private let dequeue: (IndexPath) -> DividerComponentCell
    
    lazy var size: CGSize = {
        CGSize(width: availableWidth, height: 16)
    }()
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeue(indexPath)
        return cell
    }
    
    required init(
        component: DividerComponent,
        readerSettings: ReaderSettings,
        availableWidth: CGFloat,
        dequeue: @escaping (IndexPath) -> DividerComponentCell
    ) {
        self.component = component
        self.availableWidth = availableWidth
        self.dequeue = dequeue
    }
}
