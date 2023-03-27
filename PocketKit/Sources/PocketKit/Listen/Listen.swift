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

    static let colors = PKTListenAppTheme()

    /// Analytics tracker
    private var tracker: Tracker

    init(appSession: AppSession, consumerKey: String, networkPathMonitor: NetworkPathMonitor, tracker: Tracker) {
        self.tracker = tracker
        super.init()
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
    func postAction(_ actionName: String, kusari: PKTKusari<PKTListenItem>?, data userInfo: [AnyHashable: Any]) {
        // cxt_progress will have the play progress
        // cxt_index will have the album position in the list
        // cxt_scroll_amount will have the amount seeked if seeking

        // if cxt_ui has the value background, the change came from the UI Media player controls
        var fromMPRemoteCommandCenter = false
        if let uiContext = userInfo["cxt_ui"] as? String, uiContext == "background" {
            fromMPRemoteCommandCenter = true
        }

        // TODO: If we use the Snowplow media element, we need to aquire the playback rate on all actions, which we dont have atm.
        // See MediaPlayerEntity for the options

        if actionName == "list_item_impression" {
            guard let postiton = userInfo["cxt_index"] as? Int, let url = kusari?.album?.givenURL else {
                return
            }
            self.tracker.track(event: Events.Listen.ListenItemImpression(url: url, positionInList: postiton))
        } else if actionName == "start_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "resume_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "pause_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "fast_forward_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "rewind_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "skip_next_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "skip_back_listen" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "set_speed" {
            guard let playbackSpeed = userInfo["event"] as? Double, let url = kusari?.album?.givenURL else {
                return
            }
            // user set the speed of the playback
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "reach_end_listen" {
           // user finised listening to an article
        } else if actionName == "listen_opened" {
            Log.debug("Listen action: \(actionName)")
        } else if actionName == "listen_closed" {
            Log.debug("Listen action: \(actionName)")
        } else {
            // Note there can be actions for Saving and Archiving, but we listen 😉 for those in their specific callbacks on PKTListenPocketProxy
            Log.debug("Listen action: \(actionName)")
        }
    }

    func listenDidPresentPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
    }

    func listenDidDismissPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
    }

    func listenDidDismiss() {
    }

    func itemSessionService() -> PKTItemSessionService? {
        return nil
    }

    func listenDidCollapse(intoMiniPlayer player: PKTListenAudibleQueuePresentationContext) {
        // TODO: Analytics
    }

    func listenDidCloseMiniPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
        // TODO: Analytics
    }

    func listenDidExpand(fromMiniPlayer player: PKTListenAudibleQueuePresentationContext) {
        // TODO: Analytics
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
        // TODO: Implement archiving
        Log.debug("Archive listen album: \(String(describing: kusari.albumID))")
    }

    /// User clicked save in the listen controls
    /// - Parameters:
    ///   - kusari: An object representing the item the user saved
    ///   - userInfo: Extra context info as needed
    func add(_ kusari: PKTKusari<PKTListenItem>, userInfo: [AnyHashable: Any] = [:]) {
        // TODO: Implement add
        Log.debug("Add listen album: \(String(describing: kusari.albumID))")
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
