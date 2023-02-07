import UIKit
import WebKit
import Combine

protocol VimeoComponentCellDelegate: AnyObject {
    func vimeoComponentCell(_ cell: VimeoComponentCell, didNavigateToURL: URL)
    func vimeoComponentCellDidTapOpenInWebView(_ cell: VimeoComponentCell)
}

class VimeoComponentCell: UICollectionViewCell {
    enum Mode {
        case loading(content: String?)
        case finishedLoading
        case error
    }

    var mode: Mode = .loading(content: nil) {
        didSet {
            updateContent()
        }
    }

    weak var delegate: VimeoComponentCellDelegate?

    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.limitsNavigationsToAppBoundDomains = false

        return WKWebView(frame: .zero, configuration: config)
    }()

    private let loadingView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor(.ui.grey6)
        spinner.hidesWhenStopped = false
        return spinner
    }()

    private let errorView: ArticleComponentUnavailableView = {
        let view = ArticleComponentUnavailableView()
        view.text = "This video could not be loaded.".localized()
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        webView.navigationDelegate = self
        errorView.action = { [weak self] in
            self?.invokeErrorViewAction()
        }

        contentView.addSubview(loadingView)
        contentView.addSubview(errorView)
        contentView.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            errorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            loadingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateContent() {
        switch mode {
        case .loading(let content):
            webView.isHidden = true
            errorView.isHidden = true
            loadingView.isHidden = false
            loadingView.startAnimating()

            if let htmlString = content {
                webView.loadHTMLString(htmlString, baseURL: nil)
            }
        case .finishedLoading:
            webView.isHidden = false
            errorView.isHidden = true
            loadingView.isHidden = true
            loadingView.stopAnimating()
        case .error:
            webView.isHidden = true
            errorView.isHidden = false
            loadingView.isHidden = true
            loadingView.stopAnimating()
        }
    }

    private func invokeErrorViewAction() {
        delegate?.vimeoComponentCellDidTapOpenInWebView(self)
    }
}

extension VimeoComponentCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        mode = .finishedLoading
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        mode = .error
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard case .linkActivated = navigationAction.navigationType,
              let url = navigationAction.request.url else {
            return .allow
        }

        delegate?.vimeoComponentCell(self, didNavigateToURL: url)
        return .cancel
    }
}
