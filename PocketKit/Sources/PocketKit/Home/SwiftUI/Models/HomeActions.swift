// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
