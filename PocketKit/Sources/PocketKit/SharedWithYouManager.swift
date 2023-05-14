import Foundation
import SharedWithYou
import Sync
import Combine
import SharedPocketKit
import Apollo

// Handles iOS Shared With You delegates in iOS 16 for any getpocket.com urls shared with a user.
class SharedWithYouManager: NSObject {

    public var highlightCenter: SWHighlightCenter?
    private let source: Source
    private let appSession: AppSession

    /**
     App wide subscriptions that we listen to.
     */
    private var subscriptions: Set<AnyCancellable> = []

    init(
        source: Source,
        appSession: AppSession) {

            self.source = source
            self.appSession = appSession
            super.init()

            // Register for login notifications
            NotificationCenter.default.publisher(
                for: .userLoggedIn
            ).sink { [weak self] notification in
                self?.loggedIn()
            }.store(in: &subscriptions)

            // Register for logout notifications
            NotificationCenter.default.publisher(
                for: .userLoggedOut
            ).sink { [weak self] notification in
                self?.loggedOut()
            }.store(in: &subscriptions)

            handleSessionInitilization(session: appSession.currentSession)
        }

    /**
     Handle session intitlization when not coming from a notification center subscriber. Mainly for app initilization.
     */
    private func handleSessionInitilization(session: SharedPocketKit.Session?) {
        guard session != nil     else {
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
        self.highlightCenter = SWHighlightCenter()
        self.highlightCenter!.delegate = self

        guard let highlights = self.highlightCenter?.highlights else {
            self.saveHighlightsSnapshot(highlights: [])
            return
        }

        self.saveHighlightsSnapshot(highlights: highlights)
    }

    /**
     Called when a user is logged out.
     We need to unset the highlight center because it can be called when we are logged out.
     */
    private func loggedOut() {
        self.highlightCenter?.delegate = nil
        self.highlightCenter = nil
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
