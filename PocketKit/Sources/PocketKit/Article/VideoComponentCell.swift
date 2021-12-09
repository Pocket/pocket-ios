import UIKit
import YouTubePlayerKit
import Textile

class VideoComponentCell: UICollectionViewCell {
    private lazy var loadingView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor(.ui.grey6)
        spinner.hidesWhenStopped = false
        return spinner
    }()
    
    private lazy var errorView: ArticleComponentUnavailableView = {
        let view = ArticleComponentUnavailableView()
        view.text = "This video could not be loaded."
        return view
    }()
    
    private lazy var youTubeView: YouTubePlayerHostingView = {
        let webView = YouTubePlayerHostingView(
            player: YouTubePlayer(
                source: nil,
                configuration: YouTubePlayer.Configuration(autoPlay: false)
            )
        )
        return webView
    }()
    
    var youTubePlayer: YouTubePlayer {
        youTubeView.player
    }
    
    var mode: Mode = .loading {
        didSet {
            updateMode()
        }
    }
    
    var presenter: VideoComponentPresenter? = nil
    
    var onError: (() -> Void)? {
        get {
            errorView.action
        }
        set {
            errorView.action = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(loadingView)
        contentView.addSubview(errorView)
        contentView.addSubview(youTubeView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        youTubeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            errorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            errorView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            errorView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            
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
        guard mode == .loading else {
            return
        }
        
        youTubeView.player.cue(source: .video(id: vid))
    }
    
    func pause() {
        guard mode == .loaded else {
            return
        }
        
        youTubeView.player.pause()
    }
}

private extension VideoComponentCell {
    func updateMode() {
        switch mode {
        case .loading:
            setLoading()
        case .loaded:
            setLoaded()
        case .error:
            setError()
        }
    }
    
    func setLoading() {
        loadingView.isHidden = false
        loadingView.startAnimating()
        
        youTubeView.isHidden = true
        
        errorView.isHidden = true
    }
    
    func setLoaded() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        
        youTubeView.isHidden = false
        
        errorView.isHidden = true
    }
    
    func setError() {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        
        youTubeView.isHidden = true
        
        errorView.isHidden = false
    }
}

extension VideoComponentCell {
    enum Mode {
        case loading
        case loaded
        case error
    }
}
