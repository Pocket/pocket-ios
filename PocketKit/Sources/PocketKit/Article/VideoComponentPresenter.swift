import Sync
import YouTubePlayerKit
import Combine


class VideoComponentPresenter {
    private var statePublisher: AnyCancellable? = nil
    
    func present(component: VideoComponent, in cell: VideoComponentCell) {
        cell.presenter = self
        
        statePublisher?.cancel()
        statePublisher =  cell.player.statePublisher.sink { state in
            switch state {
            case .idle:
                cell.mode = .loading
            case .ready:
                guard cell.player.source != nil else {
                    return
                }
                cell.mode = .loaded
            case .error:
                cell.mode = .error
            }
        }
        
        guard let vid = VIDExtractor(component).vid else {
            cell.mode = .error
            return
        }
        
        cell.mode = .loading
        cell.cue(vid: vid)
    }
}
