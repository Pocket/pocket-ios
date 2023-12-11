// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedWithYou
import Sync
import Combine
import SharedPocketKit
import Apollo

// Handles iOS Shared With You delegates in iOS 16 for any getpocket.com urls shared with a user.
class SharedWithYouManager: NSObject {
    private var highlightCenter: SWHighlightCenterProtocol
    private let source: Source
    private let appSession: AppSession

    /**
     App wide subscriptions that we listen to.
     */
    private var subscriptions: Set<AnyCancellable> = []

    init(
        source: Source,
        appSession: AppSession,
        highlightCenter: SWHighlightCenterProtocol
    ) {
            self.source = source
            self.appSession = appSession
            self.highlightCenter = highlightCenter
            super.init()

            // Register for login notifications
            NotificationCenter.default.publisher(
                for: .userLoggedIn
            )
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] notification in
                self?.loggedIn()
            }.store(in: &subscriptions)

            // Register for logout notifications
            NotificationCenter.default.publisher(
                for: .userLoggedOut
            )
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] notification in
                self?.loggedOut()
            }.store(in: &subscriptions)

            NotificationCenter.default.publisher(
                for: UIScene.willEnterForegroundNotification
            )
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { [weak self] notification in
                self?.handleSessionInitilization(session: self?.appSession.currentSession)
            }.store(in: &subscriptions)
        }

    /**
     Handle session intitlization when not coming from a notification center subscriber. Mainly for app initilization.
     */
    private func handleSessionInitilization(session: SharedPocketKit.Session?) {
        guard session != nil else {
            loggedOut()
            return
        }
        loggedIn()
    }

    /**
     Called when a user is logged in.
     We only set the highlight center and the delegate if a user is logged in otherwise it will get callbacks when the user is logged out
     */
    private func loggedIn() {
        self.highlightCenter.delegate = self
        self.saveHighlightsSnapshot(highlights: self.highlightCenter.highlights)
    }

    /**
     Called when a user is logged out.
     We need to unset the highlight center because it can be called when we are logged out.
     */
    private func loggedOut() {
        self.highlightCenter.delegate = nil
        self.saveHighlightsSnapshot(highlights: [])
    }

    /**
     Save our most recent highlight snapshot from the HighlightCenter
     */
    private func saveHighlightsSnapshot(highlights: [SWHighlight]) {
        // Convert to a PocketSWHighlight which is a custom simple struct that is easier to test with then SWHighlight.
        var i = 0
        let pocketHighlights = highlights.map { highlight in
            defer { i += 1 }
            return PocketSWHighlight(url: highlight.url, index: Int32(i))
        }

        do {
            // Save the highlights to CoreData and get the latest parser info for the ViewModel to pick up
            try source.saveNewSharedWithYouSnapshot(for: pocketHighlights)
        } catch {
            // Failed to save the new highlight snapshot.
            Log.capture(error: error)
        }
    }
}

extension SharedWithYouManager: SWHighlightCenterDelegate {
    func highlightCenterHighlightsDidChange(_ highlightCenter: SWHighlightCenter) {
        saveHighlightsSnapshot(highlights: highlightCenter.highlights)
    }
}
