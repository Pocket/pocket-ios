// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import WebKit
import Combine
import Localization

@MainActor
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

    var oembedSize: CGSize?

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
        view.text = Localization.thisVideoCouldNotBeLoaded
        return view
    }()

    private var preferredSize: CGSize {
        CGSize(
            width: oembedSize?.width ?? readableContentGuide.layoutFrame.width,
            height: oembedSize?.height ?? readableContentGuide.layoutFrame.width * 9 / 16
        )
    }

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

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.size.height = preferredSize.height
        return attributes
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
        layoutIfNeeded()
    }

    private func invokeErrorViewAction() {
        delegate?.vimeoComponentCellDidTapOpenInWebView(self)
    }
}

extension VimeoComponentCell: WKNavigationDelegate {
    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task {
            await setModeLoadFinished()
        }
    }

    nonisolated func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task {
            await setModeError()
        }
    }

    nonisolated func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard case .linkActivated = navigationAction.navigationType,
              let url = navigationAction.request.url else {
            return .allow
        }

        await didNavigate(to: url)
        return .cancel
    }
    /// `MainActor` isolated methods
    /// The purpose is to mantain isolated properties within the scope
    /// And make it possible to call them from within the above`nonIsolated` methods
    private func setModeLoadFinished() {
        mode = .finishedLoading
    }

    private func setModeError() {
        mode = .error
    }

    private func didNavigate(to url: URL) {
        delegate?.vimeoComponentCell(self, didNavigateToURL: url)
    }
}
