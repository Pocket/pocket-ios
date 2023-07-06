// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Sync

extension Recommendation {
    var bestImageURL: URL? {
        guard let topImageURL = imageURL ?? item.syndicatedArticle?.imageURL ?? item.topImageURL ?? (item.images?.firstObject as? Image)?.source else {
            return nil
        }

        return CDNURLBuilder().imageCacheURL(for: topImageURL)
    }

    var bestDomain: String? {
        item.syndicatedArticle?.publisherName
        ?? item.domainMetadata?.name
        ?? item.domain
        ?? URL(percentEncoding: item.bestURL)?.host
        ?? "" // TODO: What should be the final fallback string?
    }

    var bestTitle: String? {
        title ?? item.syndicatedArticle?.title ?? item.title
    }

    var bestExcerpt: String? {
        excerpt ?? item.syndicatedArticle?.excerpt ?? item.excerpt
    }
}
