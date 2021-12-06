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
            case .idle, .error:
                cell.mode = .loading
            case .ready:
                cell.mode = .loaded
            }
        }
        
        cell.mode = .loading
        let vid = VIDExtractor(component).vid!
        cell.cue(vid: vid)
    }
}
