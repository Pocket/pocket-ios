import Sync
import YouTubePlayerKit
import Combine
import CoreGraphics
import UIKit


class YouTubeVideoComponentPresenter: ArticleComponentPresenter {
    private let component: VideoComponent
    
    private var cancellable: AnyCancellable? = nil
    
    init(component: VideoComponent) {
        self.component = component
    }
    
    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: availableWidth * 9 / 16)
    }
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: YouTubeVideoComponentCell = collectionView.dequeueCell(for: indexPath)
        
        cancellable =  cell.player
            .statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak cell] state in
                switch state {
                case .idle:
                    cell?.mode = .loading
                case .ready:
                    guard cell?.player.source != nil else {
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

    func clearCache() {
        // no op
    }
}
