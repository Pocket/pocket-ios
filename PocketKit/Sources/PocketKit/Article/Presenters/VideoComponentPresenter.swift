import Sync
import YouTubePlayerKit
import Combine
import CoreGraphics
import UIKit


class VideoComponentPresenter: ArticleComponentPresenter {
    private let component: VideoComponent
    private let availableWidth: CGFloat
    private let dequeue: (IndexPath) -> VideoComponentCell
    
    private var cancellable: AnyCancellable? = nil
    
    init(component: VideoComponent, availableWidth: CGFloat, dequeue: @escaping (IndexPath) -> VideoComponentCell) {
        self.component = component
        self.availableWidth = availableWidth
        self.dequeue = dequeue
    }
    
    lazy var size: CGSize = {
        CGSize(width: availableWidth, height: availableWidth * 9 / 16)
    }()
    
    func cell(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeue(indexPath)
        
        cancellable =  cell.youTubePlayer.statePublisher.receive(on: DispatchQueue.main).sink { [weak cell] state in
            switch state {
            case .idle:
                cell?.mode = .loading
            case .ready:
                guard cell?.youTubePlayer.source != nil else {
                    return
                }
                cell?.mode = .loaded
            case .error:
                cell?.mode = .error
            }
        }
        
        guard let vid = VIDExtractor(component).vid else {
            cell.mode = .error
            return cell
        }
        
        cell.mode = .loading
        cell.cue(vid: vid)
        
        return cell
    }
}
