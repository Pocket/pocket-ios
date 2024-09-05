// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Combine
import PKTListen
import Sync
import Analytics
import Network

class Listen: NSObject {
    private var subscriptions: Set<AnyCancellable> = []

    static let colors = ListenTheme()

    /// Analytics tracker
    private let tracker: Tracker

    /// Service used to  archive or save an article
    private let source: Source

    init(appSession: AppSession, consumerKey: String, networkPathMonitor: NetworkPathMonitor, tracker: Tracker, source: Source) {
        self.tracker = tracker
        self.source = source
        super.init()
        // Set a default set of languages that the server will overwrite when it loads
        PKTListen.supportedLanguages = ["en"]
        PKTSetConsumerKey(consumerKey)
        PKTLocalRuntime.shared().start()
        PKTListen.sharedInstance().sessionDelegate = self
        PKTListen.sharedInstance().pocketProxy = self

        // Register for login notifications
        NotificationCenter.default.publisher(
            for: .userLoggedIn
        ).sink { [weak self] notification in
            self?.handleSession(session: notification.object as? SharedPocketKit.Session)
            guard (notification.object as? SharedPocketKit.Session) != nil else {
                return
            }
        }.store(in: &subscriptions)

        // Register for logout notifications
        NotificationCenter.default.publisher(
            for: .userLoggedOut
        ).sink { [weak self] notification in
            self?.handleSession(session: nil)
        }.store(in: &subscriptions)
        // Because session could already be available at init, lets try and use it.
        handleSession(session: appSession.currentSession)

        networkPathMonitor.updateHandler = { [weak self] path in
            guard let self else {
                Log.capture(message: "weak self in listen network")
                return
            }
            self.setNetworkStatus(status: path.status)
        }

        setNetworkStatus(status: networkPathMonitor.currentNetworkPath.status)
    }

    func setNetworkStatus(status: NWPath.Status) {
        switch status {
        case .satisfied:
            PKTListenAppConfiguration.setConnection(.typeWiFi)
        case .unsatisfied:
            PKTListenAppConfiguration.setConnection(.typeNone)
        case .requiresConnection:
            PKTListenAppConfiguration.setConnection(.typeUnknown)
        default:
            PKTListenAppConfiguration.setConnection(.typeUnknown)
        }
    }

    /**
     Handles a session if it exists.
     */
    func handleSession(session: SharedPocketKit.Session?) {
        guard let session = session else {
            // If the session is nil, ensure the user's view is logged out
            self.tearDownSession()
            return
        }

        // We have a session! Ensure the user is logged in.
        self.setUpSession(session)
    }

    private func setUpSession(_ session: SharedPocketKit.Session) {
        PKTSetAccessToken(session.accessToken)
        PKTSetGUID(session.guid)

        PKTListen.updateSettings()
        PKTUser.loggedIn().hasSignedUp = false
    }

    private func tearDownSession() {
        PKTSetAccessToken(nil)
        PKTSetGUID(nil)
    }
}

extension Listen: PKTListenServiceDelegate {
    static let skippedActions = [
        "listen_opened",
        "listen_closed"
    ]

    func postAction(_ actionName: String, kusari: PKTKusari<PKTListenItem>?, data userInfo: [AnyHashable: Any]) {
        // cxt_progress will have the play progress
        // cxt_index will have the album position in the list
        // cxt_scroll_amount will have the amount seeked if seeking

        // if cxt_ui has the value background, the change came from the UI Media player controls
        var controlType: Events.Listen.ControlType = .inapp
        if let uiContext = userInfo["cxt_ui"] as? String, uiContext == "background" {
            controlType = .system
        }

        if Self.skippedActions.contains(actionName) {
            // Skip logging action because we handle it elsewhere.
            return
        }

        Log.breadcrumb(category: "listen", level: .info, message: "Performed \(actionName) via \(controlType)")

        guard let url = kusari?.album?.givenURL?.absoluteString else {
            Log.capture(message: "Listen action occurred without an item url")
            return
        }

        // TODO: If we use the Snowplow media element, we need to aquire the playback rate on all actions, which we dont have atm.
        // See MediaPlayerEntity for the options

        if actionName == "list_item_impression" {
            guard let postiton = userInfo["cxt_index"] as? Int else {
                return
            }
            tracker.track(event: Events.Listen.ItemImpression(url: url, positionInList: postiton))
        } else if actionName == "start_listen" {
            tracker.track(event: Events.Listen.StartPlayback(url: url, controlType: controlType))
        } else if actionName == "resume_listen" {
            tracker.track(event: Events.Listen.ResumePlayback(url: url, controlType: controlType))
        } else if actionName == "pause_listen" {
            tracker.track(event: Events.Listen.PausePlayback(url: url, controlType: controlType))
        } else if actionName == "fast_forward_listen" {
            tracker.track(event: Events.Listen.FastForward(url: url, controlType: controlType))
        } else if actionName == "rewind_listen" {
            tracker.track(event: Events.Listen.Rewind(url: url, controlType: controlType))
        } else if actionName == "skip_next_listen" {
            tracker.track(event: Events.Listen.SkipNext(url: url, controlType: controlType))
        } else if actionName == "skip_back_listen" {
            tracker.track(event: Events.Listen.SkipBack(url: url, controlType: controlType))
        } else if actionName == "set_speed" {
            guard let playbackSpeed = userInfo["event"] as? Double else {
                return
            }
            // TODO: This is not currently being triggered by Listen
            tracker.track(event: Events.Listen.SetSpeed(url: url, controlType: controlType, speed: playbackSpeed))
        } else if actionName == "reach_end_listen" {
            tracker.track(event: Events.Listen.FinsihedListen(url: url, controlType: controlType))
        }
        // Note there can be actions for Saving and Archiving, Closing, but we listen 😉 for those in their specific callbacks on PKTListenPocketProxy
    }

    func listenDidPresentPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
        tracker.track(event: Events.Listen.Opened())
    }

    func listenDidDismissPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
    }

    func listenDidDismiss() {
        tracker.track(event: Events.Listen.Closed())
    }

    func itemSessionService() -> PKTItemSessionService? {
        return nil
    }

    func listenDidCollapse(intoMiniPlayer player: PKTListenAudibleQueuePresentationContext) {
        tracker.track(event: Events.Listen.Collapsed())
    }

    func listenDidCloseMiniPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
        tracker.track(event: Events.Listen.MiniClosed())
    }

    func listenDidExpand(fromMiniPlayer player: PKTListenAudibleQueuePresentationContext) {
        tracker.track(event: Events.Listen.Expanded())
    }

    func currentColors() -> PKTUITheme {
        return Listen.colors
    }
}

extension Listen: PKTListenPocketProxy {
    /// User clicked archive in the listen controls
    /// - Parameters:
    ///   - kusari: An object representing the item the user saved
    ///   - userInfo: Extra context info as needed
    func archiveKusari(_ kusari: PKTKusari<PKTListenItem>, userInfo: [AnyHashable: Any] = [:]) {
        guard let savedItem = kusari.album as? CDSavedItem else {
            Log.capture(message: "Tried to archive item from Listen where we dont have the SavedItem")
            return
        }

        self.source.archive(item: savedItem)

        guard let postiton = userInfo["cxt_index"] as? Int else {
            Log.capture(message: "Tried to archive item from Listen where we dont have the Index, not logging analytics")
            return
        }
        self.tracker.track(event: Events.Listen.Archived(url: savedItem.url, position: postiton))
    }

    /// User clicked save in the listen controls
    /// - Parameters:
    ///   - kusari: An object representing the item the user saved
    ///   - userInfo: Extra context info as needed
    func add(_ kusari: PKTKusari<PKTListenItem>, userInfo: [AnyHashable: Any] = [:]) {
        guard let url = kusari.album?.givenURL?.absoluteString else {
            Log.capture(message: "Tried to save item from Listen where we dont have the url")
            return
        }
        _ = self.source.save(url: url)

        guard let postiton = userInfo["cxt_index"] as? Int else {
            Log.capture(message: "Tried to add item from Listen where we dont have the Index, not logging analytics")
            return
        }
        self.tracker.track(event: Events.Listen.MoveFromArchiveToSaves(url: url, position: postiton))
    }

    /// TODO: Ask nicole
    /// - Parameter album: The album to refresh
    /// - Returns: A PKTListenItem that was refreshed to send back to Listen
    func refreshAlbum(_ album: PKTListenItem) async -> PKTListenItem {
        // TODO: Implement refresh?
        // TODO: Ask nicole when this can happen
        Log.debug("Refresh listen album: \(String(describing: album.albumID))")
        return album
    }

    func store() -> PKTKeyValueStore {
        PKTLocalRuntime.shared().store()
    }
}
