// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
@preconcurrency import Sync

// TODO: SWIFTUI - Add analytics
/// Type that contains all the actions that can be performed from Home and its detail views
struct HomeActions {
    // TODO: SWIFTUI - the following methods use a reference to Services that only lives in their scope.
    // This is on purpose since we do not want to keep a reference in the model, and once we are fully
    // migrated to SwiftUI we will likely leverage the environment for dependency injection.
    @MainActor
    func saveAction(isSaved: Bool, givenURL: String) {
        let source = Services.shared.source
        if isSaved {
            source.archive(from: givenURL)
        } else {
            source.save(from: givenURL)
        }
    }

    @MainActor
    func archiveAction(givenURL: String) {
        let source = Services.shared.source
        source.archive(from: givenURL)
    }

    @MainActor
    func deleteAction(givenURL: String) {
        let source = Services.shared.source
        source.delete(from: givenURL)
    }

    @MainActor
    func favoriteAction(isFavorite: Bool, givenURL: String) {
        let source = Services.shared.source
        if isFavorite {
            source.unFavorite(givenURL)
        } else {
            source.favorite(givenURL)
        }
    }

    func shareableUrl(shareURL: String?, givenURL: String) async -> String? {
        let source = await Services.shared.source
        if let shareURL {
            return shareURL
        } else {
            let remoteShareUrl = try? await source.requestShareUrl(givenURL)
            return remoteShareUrl
        }
    }

    func fetchCollection(slug: String) async {
        let source = await Services.shared.source
        try? await source.fetchCollection(by: slug)
    }
}

// MARK: Analytics
extension HomeActions {
    func trackCardImpression(_ type: CardType, url: String, index: Int? = nil, recommendationID: String? = nil) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch type {
            case .recentSave:
                tracker.track(event: Events.Home.RecentSavesCardImpression(url: url, positionInList: index))
            case .recommendation:
                guard let recommendationID else { return }
                tracker.track(event: Events.Home.SlateArticleImpression(url: url, positionInList: index, recommendationId: recommendationID))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouCardImpression(url: url, positionInList: index))
            case .collectionStory:
                tracker.track(event: Events.Collection.storyImpression(url: url, positionInList: index))
            case .slateDetail:
                guard let recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.SlateArticleImpression(url: url, positionInList: index, recommendationId: recommendationID))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.cardImpression(url: url, index: index))
            }
        }
    }

    func trackCardContentOpen(_ type: CardType, url: String, index: Int? = nil, recommendationID: String? = nil, externalDestination: Bool) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch type {
            case .recentSave:
                tracker.track(event: Events.Home.RecentSavesCardContentOpen(url: url, positionInList: index))
            case .recommendation:
                guard let recommendationID else { return }
                tracker.track(event: Events.Home.SlateArticleContentOpen(url: url, positionInList: index, recommendationId: recommendationID, destination: externalDestination ? .external : .internal))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouContentOpen(url: url, positionInList: index, destination: externalDestination ? .external : .internal))
            case .collectionStory:
                tracker.track(event: Events.Collection.contentOpen(url: url))
            case .slateDetail:
                guard let recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.SlateArticleContentOpen(url: url, positionInList: index, recommendationId: recommendationID, destination: externalDestination ? .external : .internal))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.contentOpen(url: url, index: index, destination: externalDestination ? .external : .internal))
            }
        }
    }
}
