import UIKit
import YouTubePlayerKit

class VideoComponentCell: UICollectionViewCell {
    private lazy var youTubeView: YouTubePlayerHostingView = {
        let webView = YouTubePlayerHostingView(
            player: YouTubePlayer(
                source: nil,
                configuration: YouTubePlayer.Configuration(autoPlay: false)
            )
        )
        return webView
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor(.ui.grey6)
        spinner.hidesWhenStopped = false
        return spinner
    }()
    
    var player: YouTubePlayer {
        youTubeView.player
    }
    
    var mode: Mode = .loading {
        didSet {
            updateMode()
        }
    }
    
    var presenter: VideoComponentPresenter? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(spinner)
        contentView.addSubview(youTubeView)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        youTubeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            youTubeView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            youTubeView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            youTubeView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            youTubeView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
    
    func cue(vid: String) {
        youTubeView.player.cue(source: .video(id: vid))
    }
    
    func pause() {
        youTubeView.player.pause()
    }
}

private extension VideoComponentCell {
    func updateMode() {
        switch mode {
        case .loading:
            youTubeView.isHidden = true
            spinner.isHidden = false
            spinner.startAnimating()
        case .loaded:
            spinner.stopAnimating()
            spinner.isHidden = true
            youTubeView.isHidden = false
        }
    }
}

extension VideoComponentCell {
    enum Mode {
        case loading
        case loaded
    }
}
