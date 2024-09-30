// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
@preconcurrency import Sync
import SwiftUI
import Textile

// TODO: SWIFTUI - Add analytics

/// Representation of an `Item` suitable for being displayed in a `Hero` or a `Carousel` card.
@MainActor
struct HomeCard: Identifiable, @preconcurrency Equatable {
    static func == (lhs: HomeCard, rhs: HomeCard) -> Bool {
        lhs.givenURL == rhs.givenURL &&
        lhs.imageURL == rhs.imageURL &&
        lhs.sharedWithYouUrlString == rhs.sharedWithYouUrlString
    }

    var id = UUID()
    let givenURL: String
    let imageURL: URL?
    let sharedWithYouUrlString: String?
    let shareURL: String?
    let useLargeTitle: Bool

    // actions configuration
    let enableSaveAction: Bool
    let enableFavoriteAction: Bool
    // menu actions configuration
    let enableShareMenuAction: Bool
    let enableReportMenuAction: Bool
    let enableArchiveMenuAction: Bool
    let enableDeleteMenuAction: Bool

    init(
        givenURL: String,
        imageURL: URL?,
        sharedWithYouUrlString: String? = nil,
        ShareURL: String? = nil,
        uselargeTitle: Bool = false,
        enableSaveAction: Bool = false,
        enableFavoriteAction: Bool = false,
        enableShareMenuAction: Bool = false,
        enableReportMenuAction: Bool = false,
        enableArchiveMenuAction: Bool = false,
        enableDeleteMenuAction: Bool = false
    ) {
        self.givenURL = givenURL
        self.imageURL = imageURL
        self.sharedWithYouUrlString = sharedWithYouUrlString
        self.shareURL = ShareURL
        self.useLargeTitle = uselargeTitle
        self.enableSaveAction = enableSaveAction
        self.enableFavoriteAction = enableFavoriteAction
        self.enableShareMenuAction = enableShareMenuAction
        self.enableReportMenuAction = enableReportMenuAction
        self.enableArchiveMenuAction = enableArchiveMenuAction
        self.enableDeleteMenuAction = enableDeleteMenuAction
    }
}

// MARK: Actions
extension HomeCard {
    // TODO: SWIFTUI - the following methods use a reference to Services that only lives in their scope.
    // This is on purpose since we do not want to keep a reference in the model, and once we are fully
    // migrated to SwiftUI we will likely leverage the environment for dependency injection.
    func saveAction(isSaved: Bool) {
        let source = Services.shared.source
        if isSaved {
            source.archive(from: givenURL)
        } else {
            source.save(from: givenURL)
        }
    }

    func archiveAction() {
        let source = Services.shared.source
        source.archive(from: givenURL)
    }

    func deleteAction() {
        let source = Services.shared.source
        source.delete(from: givenURL)
    }

    func favoriteAction(isFavorite: Bool, givenURL: String) {
        let source = Services.shared.source
        if isFavorite {
            source.unFavorite(givenURL)
        } else {
            source.favorite(givenURL)
        }
    }

    func shareableUrl() async -> String? {
        let source = Services.shared.source
        if let shareURL {
            return shareURL
        } else {
            let remoteShareUrl = try? await source.requestShareUrl(givenURL)
            return remoteShareUrl
        }
    }
}

// MARK: Styler
extension HomeCard {
    var collectionStyle: Style {
        .recommendation.collection
    }

    // TODO: SWIFTUI - use the proper style here once we do native collections
    var attributedExcerpt: AttributedString? {
        return nil
    }

    var titleStyle: Style {
        .recommendation.adaptiveTitle(useLargeTitle)
    }

    var domainStyle: Style {
        .recommendation.domain
    }

    func timeToRead(_ timeToRead: Int32) -> AttributedString {
        AttributedString(NSAttributedString(string: Localization.Home.Recommendation.readTime(timeToRead), style: .recommendation.timeToRead))
    }
}
