// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile
import SharedPocketKit
import SharedWithYou

class SharedWithYouCarouselCell: UICollectionViewCell {
    let topView: HomeCarouselViewUIKit

    /// The top-most stack view, that allows to add accessory views.
    /// If no accessory view is present, it only contains `topView`
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topView, attributionView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private(set) lazy var attributionView: SWAttributionView = {
        let attributionView = SWAttributionView()
        attributionView.translatesAutoresizingMaskIntoConstraints = false
        attributionView.displayContext = .summary
        return attributionView
    }()

    override init(frame: CGRect) {
        topView = HomeCarouselViewUIKit(frame: .zero)
        super.init(frame: frame)
        topView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topStackView)
        contentView.pinSubviewToAllEdges(topStackView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: configuration
extension SharedWithYouCarouselCell {
    func configure(with configuration: HomeCarouselCellConfiguration) {
        topView.configure(with: configuration)

        if let url = configuration.sharedWithYouUrlString {
            Task {
                await updateAttributionView(url)
            }
        }
    }
}

// MARK: private helpers
extension SharedWithYouCarouselCell {
    /// Add the attribution view if a valid shared with you url is found
    /// - Parameter urlString: the string representation of the url
    private func updateAttributionView(_ urlString: String) async {
        guard let url = URL(string: urlString) else {
            return
        }
        do {
            let highlight = try await SWHighlightCenter().highlight(for: url)
            attributionView.highlight = highlight
        } catch {
            Log.capture(message: "SWH: carousel cell configuration - Unable to retrieve highlight for url: \(urlString) - Error: \(error)")
        }
    }
}
