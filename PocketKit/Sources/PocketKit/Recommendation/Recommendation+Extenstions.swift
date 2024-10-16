// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Sync

extension CDRecommendation {
    var bestImageURL: URL? {
        guard let topImageURL = imageURL ?? item.syndicatedArticle?.imageURL ?? item.topImageURL ?? (item.images?.firstObject as? CDImage)?.source else {
            return nil
        }

        return CDNURLBuilder().imageCacheURL(for: topImageURL)
    }

    var bestDomain: String? {
        item.bestDomain
    }

    var bestTitle: String? {
        title ?? item.syndicatedArticle?.title ?? item.title
    }

    var bestExcerpt: String? {
        excerpt ?? item.syndicatedArticle?.excerpt ?? item.excerpt
    }
}
