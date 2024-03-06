// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Foundation
import SharedPocketKit
import SharedWithYou
import Sync

/// Shared With You highlights store
final class SharedWithYouStore: NSObject {
    private let highlightCenter: SWHighlightCenter
    private let source: Source
    private let appSession: AppSession

    private var subscriptions = Set<AnyCancellable>()

    private(set) var highlights: [SWHighlight]

    init(highlightCenter: SWHighlightCenter? = nil, source: Source, appSession: AppSession) {
        self.highlightCenter = highlightCenter ?? SWHighlightCenter()
        self.highlights = self.highlightCenter.highlights
        self.source = source
        self.appSession = appSession
        super.init()
        if appSession.currentSession != nil {
            start()
        }
        listenForUserSession()
    }
}

// MARK: Shared With You delegate
extension SharedWithYouStore: SWHighlightCenterDelegate {
    /// Emits changes in the shared with you list associated with the app
    func highlightCenterHighlightsDidChange(_ highlightCenter: SWHighlightCenter) {
        // if the list is different (either by elements or sort order) replace it
        if highlightCenter.highlights != self.highlights {
            self.highlights = highlightCenter.highlights
            // Update local storage with the new highlights, which will trigger a UI update
            // via the associated RichFetchedResultController
            source.updateSharedWithYouItems(with: highlightCenter.highlights.map { $0.url.absoluteString })
        }
    }
}

// MARK: private helpers
private extension SharedWithYouStore {
    func start() {
        self.highlightCenter.delegate = self
    }

    func stop() {
        self.highlightCenter.delegate = nil
    }

    func listenForUserSession() {
        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] _ in
            self?.start()
        }.store(in: &subscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { [weak self] _ in
            self?.stop()
        }.store(in: &subscriptions)
    }
}
