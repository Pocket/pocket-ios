import UIKit
import YouTubePlayerKit
import Textile

class YouTubeVideoComponentCell: UICollectionViewCell {
    private lazy var loadingView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor(.ui.grey6)
        spinner.hidesWhenStopped = false
        return spinner
    }()

    private lazy var errorView: ArticleComponentUnavailableView = {
        let view = ArticleComponentUnavailableView()
        view.text = "This video could not be loaded.".localized()
        return view
    }()

    private lazy var hostingView: YouTubePlayerHostingView = {
        let webView = YouTubePlayerHostingView(
            player: YouTubePlayer(
                source: nil,
                configuration: YouTubePlayer.Configuration(autoPlay: false)
            )
        )
        return webView
    }()

    var player: YouTubePlayer {
        hostingView.player
    }

    var mode: Mode = .loading {
        didSet {
            updateMode()
        }
    }

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
        contentView.addSubview(hostingView)

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            errorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            errorView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            errorView.heightAnchor.constraint(equalTo: contentView.heightAnchor),

            hostingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            hostingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            hostingView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            hostingView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }

    func cue(vid: String) {
        player.cue(source: .video(id: vid))
    }

    func pause() {
        guard mode == .loaded else {
            return
        }

        player.pause()
    }
}

private extension YouTubeVideoComponentCell {
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

        hostingView.isHidden = true

        errorView.isHidden = true
    }

    func setLoaded() {
        loadingView.stopAnimating()
        loadingView.isHidden = true

        hostingView.isHidden = false

        errorView.isHidden = true
    }

    func setError() {
        loadingView.stopAnimating()
        loadingView.isHidden = true

        hostingView.isHidden = true

        errorView.isHidden = false
    }
}

extension YouTubeVideoComponentCell {
    enum Mode {
        case loading
        case loaded
        case error
    }
}
