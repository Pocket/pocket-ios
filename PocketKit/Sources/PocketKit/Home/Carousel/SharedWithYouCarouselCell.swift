// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile
import SharedPocketKit
import SharedWithYou

/// Shared with you cell, inherits from the standard carousel cell and adds the attribution view
class SharedWithYouCarouselCell: HomeCarouselCell {
    /// Add the attribution view if a valid url is found
    /// - Parameter urlString: the string representation of the url
    private func addAttributionView(_ urlString: String) async {
        guard let url = URL(string: urlString) else {
            return
        }
        // no need to re-add the same attribution view
        if let highlight = attributionView.highlight, highlight.url.absoluteString == urlString, attributionView.isDescendant(of: topStackView) {
            return
        }
        do {
            let highlight = try await SWHighlightCenter().highlight(for: url)
            attributionView.highlight = highlight
            // in case of reusing a cell, we just need to change the highlight without readding the attribution view to the hierarchy
            if !attributionView.isDescendant(of: topStackView) {
                topStackView.addArrangedSubview(attributionView)
            }
        } catch {
            Log.capture(message: "Unable to retrieve highlight for url: \(urlString) - Error: \(error)")
        }
    }

    private lazy var attributionView: SWAttributionView = {
        let attributionView = SWAttributionView()
        attributionView.translatesAutoresizingMaskIntoConstraints = false
        attributionView.displayContext = .summary
        return attributionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with configuration: HomeCarouselCellConfiguration) {
        super.configure(with: configuration)

        if let url = configuration.sharedWithYouUrlString {
            Task {
                await addAttributionView(url)
            }
        }
    }
}
