// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
@preconcurrency import Sync
import SwiftUI

// TODO: SWIFTUI - Add analytics
/// Type that contains all the actions that can be performed from Home and its detail views
struct HomeActions {
    // TODO: SWIFTUI - the methods here use a reference to Services that only lives in their scope.
    // This is on purpose since we do not want to keep a reference here, and once we are fully
    // migrated to SwiftUI we will likely leverage the environment or something like swift-dependencies
    // https://github.com/pointfreeco/swift-dependencies for dependency injection.

    /// Prompts the FxA login
    @MainActor
    func requestAuthentication(_ type: CardType) {
        /// **NOTE: recommendation, collection and collectionStory are the only three types of source handled from SwiftUI Home
        var loginSource: Events.SignedOut.LoginSource = .recommendationCard
        if type == .collection {
            loginSource = .collection
        } else if type == .collectionStory {
            loginSource = .collectionStory
        }
        Services.shared.accessService.requestAuthentication(loginSource)
    }

    @MainActor
    func saveAction(isSaved: Bool, givenURL: String, info: ItemInfo) {
        if Services.shared.accessService.accessLevel.isAnonymous {
            requestAuthentication(info.type)
        } else if Services.shared.accessService.accessLevel.isAuthenticated {
            let source = Services.shared.source
            if isSaved {
                source.archive(from: givenURL)
                trackArchive(info)
            } else {
                source.save(from: givenURL)
                trackSave(info)
            }
        }
    }

    @MainActor
    func archiveAction(givenURL: String, info: ItemInfo) {
        let source = Services.shared.source
        source.archive(from: givenURL)
        trackArchive(info)
    }

    @MainActor
    func deleteAction(givenURL: String, info: ItemInfo) {
        let source = Services.shared.source
        source.delete(from: givenURL)
        trackDelete(info)
    }

    @MainActor
    func favoriteAction(isFavorite: Bool, givenURL: String, info: ItemInfo) {
        let source = Services.shared.source
        if isFavorite {
            source.unFavorite(givenURL)
            trackUnFavorite(info)
        } else {
            source.favorite(givenURL)
            trackFavorite(info)
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

    /// Refresh recommendations
    /// - Parameters:
    ///   - isForced: Whether or not the user forced the refresh
    @MainActor
    func refreshRecommendations(isForced: Bool = false) async {
        await Services.shared.homeRefreshCoordinator.refresh(isForced: isForced)
    }
}

// MARK: Analytics
extension HomeActions {
    func trackHomeScreenImpression() {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            tracker.track(event: Events.Home.homeScreenImpression())
        }
    }

    func trackSlateDetailImpression(_ slateID: String) {
        Task(priority: .background) {
            let source = await Services.shared.source
            guard let slate = source.fetchSlate(slateID) else {
                return
            }
            let tracker = await Services.shared.tracker
            var sortIndex: Int?
            if let index = slate.sortIndex {
                sortIndex = Int(truncating: index)
            }
            tracker.track(
                event: Events.ExpandedSlate.slateExpanded(
                    slateId: slateID,
                    slateRequestId: slate.requestID,
                    slateExperimentId: slate.experimentID,
                    slateIndex: sortIndex ?? 0,
                    slateLineupId: slate.slateLineup?.remoteID ?? ""
                )
            )
        }
    }

    func trackCardImpression(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardImpression(url: info.url, positionInList: info.index))
            case .recommendation:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.Home.slateArticleImpression(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouCardImpression(url: info.url, positionInList: info.index))
            case .collectionStory:
                tracker.track(event: Events.Collection.storyImpression(url: info.url, positionInList: info.index))
            case .slateDetail:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.slateArticleImpression(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.cardImpression(url: info.url, index: info.index))
            case .collection:
                tracker.track(event: Events.Collection.screenView())
            }
        }
    }

    func trackCardContentOpen(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardContentOpen(url: info.url, positionInList: info.index))
            case .recommendation:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.Home.slateArticleContentOpen(url: info.url, positionInList: info.index, recommendationId: recommendationID, destination: info.externalDestination ? .external : .internal))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouContentOpen(url: info.url, positionInList: info.index, destination: info.externalDestination ? .external : .internal))
            case .collectionStory:
                tracker.track(event: Events.Collection.contentOpen(url: info.url))
            case .slateDetail:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.slateArticleContentOpen(url: info.url, positionInList: info.index, recommendationId: recommendationID, destination: info.externalDestination ? .external : .internal))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.contentOpen(url: info.url, index: info.index, destination: info.externalDestination ? .external : .internal))
            case .collection:
                break // no content open event for collection, the content open is handled by the source card
            }
        }
    }

    func trackSave(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                break // by definition, recent saves cannot be saved again
            case .recommendation:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.Home.slateArticleSave(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouItemSave(url: info.url, positionInList: info.index))
            case .collectionStory:
                tracker.track(event: Events.Collection.saveClicked(url: info.url))
            case .slateDetail:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.slateArticleSave(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.itemSaved(url: info.url, index: info.index))
            case .collection:
                tracker.track(event: Events.Collection.saveClicked(url: info.url))
            }
        }
    }

    func trackShare(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardShare(url: info.url, positionInList: info.index))
            case .recommendation:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.Home.slateArticleShare(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouItemShare(url: info.url, positionInList: info.index))
            case .collectionStory:
                tracker.track(event: Events.Collection.shareClicked(url: info.url))
            case .slateDetail:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.slateArticleShare(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.itemShared(url: info.url, index: info.index))
            case .collection:
                tracker.track(event: Events.Collection.shareClicked(url: info.url))
            }
        }
    }

    func trackArchive(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardArchive(url: info.url, positionInList: info.index))
            case .recommendation:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.Home.slateArticleArchive(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYou:
                tracker.track(event: Events.Home.sharedWithYouItemArchive(url: info.url, positionInList: info.index))
            case .collectionStory:
                tracker.track(event: Events.Collection.unsaveClicked(url: info.url))
            case .slateDetail:
                guard let recommendationID = info.recommendationID else { return }
                tracker.track(event: Events.ExpandedSlate.slateArticleArchive(url: info.url, positionInList: info.index, recommendationId: recommendationID))
            case .sharedWithYouDetail:
                tracker.track(event: Events.SharedWithYou.itemArchived(url: info.url, index: info.index))
            case .collection:
                tracker.track(event: Events.Collection.unsaveClicked(url: info.url))
            }
        }
    }

    func trackFavorite(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardFavorite(url: info.url, positionInList: info.index))
            case .collection:
                tracker.track(event: Events.Collection.favoriteClicked(url: info.url))
            default:
                break // only recent saves and collections can be favorited. Events from the reader are handled in UIKit for now.
            }
        }
    }

    func trackUnFavorite(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardUnfavorite(url: info.url, positionInList: info.index))
            case .collection:
                tracker.track(event: Events.Collection.unfavoriteClicked(url: info.url))
            default:
                break // only recent saves and collections can be unfavorited. Events from the reader are handled in UIKit for now.
            }
        }
    }

    func trackDelete(_ info: ItemInfo) {
        Task(priority: .background) {
            let tracker = await Services.shared.tracker
            switch info.type {
            case .recentSave:
                tracker.track(event: Events.Home.recentSavesCardDelete(url: info.url, positionInList: info.index))
            case .collection:
                tracker.track(event: Events.Collection.deleteClicked(url: info.url))
            default:
                break // only recent saves and collections can be deleted. Events from the reader are handled in UIKit for now.
            }
        }
    }
}
