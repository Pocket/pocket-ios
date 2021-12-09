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
    
    private lazy var errorView: ErrorView = {
        return ErrorView()
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

private extension Style {
    static let errorLabel: Self = .body.sansSerif.with(size: .p3)
    static let errorButton: Self = .body.sansSerif.with(size: .p3).with(color: .ui.white).with(weight: .semibold)
}

extension VideoComponentCell {
    class ErrorView: UIView {
        private lazy var label: UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString(
                string: "This video could not be loaded.",
                style: .errorLabel
            )
            return label
        }()
        
        private lazy var button: UIButton = {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor(.ui.teal2)
            config.attributedTitle = AttributedString(
                NSAttributedString(
                    string: "Open in Web View",
                    style: .errorButton
                )
            )
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            
            let button = UIButton(
                configuration: config,
                primaryAction: UIAction { _ in
                    self.action?()
                }
            )
            return button
        }()
        
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [label, button])
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.alignment = .center
            return stackView
        }()
        
        private lazy var topDivider: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(.ui.grey6)
            return view
        }()
        
        private lazy var bottomDivider: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(.ui.grey6)
            return view
        }()
        
        var action: (() -> Void)? = nil
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(topDivider)
            addSubview(stackView)
            addSubview(bottomDivider)
            
            topDivider.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            bottomDivider.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                topDivider.topAnchor.constraint(equalTo: topAnchor),
                topDivider.widthAnchor.constraint(equalTo: widthAnchor),
                topDivider.heightAnchor.constraint(equalToConstant: 1),
                
                stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
                stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
                
                bottomDivider.bottomAnchor.constraint(equalTo: bottomAnchor),
                bottomDivider.widthAnchor.constraint(equalTo: widthAnchor),
                bottomDivider.heightAnchor.constraint(equalToConstant: 1),
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
        }
    }
}
