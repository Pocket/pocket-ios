// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Combine
import PKTListen
import Sync

class ListenRuntime: NSObject {
    private var subscriptions: Set<AnyCancellable> = []

    static let colors = PKTListenAppTheme()

    init(appSession: AppSession, consumerKey: String) {
        super.init()
        PKTLocalRuntime.shared().start()
        PKTSetConsumerKey(consumerKey)
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

extension ListenRuntime: PKTListenServiceDelegate {
    func postAction(_ actionName: String, kusari: PKTKusari<PKTListenItem>?, data userInfo: [AnyHashable: Any]) {
        Log.debug("Listen action: \(actionName)")
        // listen_opened
        // listen_clised
        // list_item_impression
        // reach_end_listen
        // See PKTListenItemSession for full list.
        // kusari?.album.
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
    }

    func listenDidCloseMiniPlayer(_ player: PKTListenAudibleQueuePresentationContext) {
    }

    func listenDidExpand(fromMiniPlayer player: PKTListenAudibleQueuePresentationContext) {
    }

    func currentColors() -> PKTUITheme {
        return ListenRuntime.colors
    }
}

extension ListenRuntime: PKTListenPocketProxy {
    func archiveKusari(_ kusari: PKTKusari<PKTListenItem>, userInfo: [AnyHashable: Any] = [:]) {
        // TODO: Implement archiving
        Log.debug("Archive listen album: \(String(describing: kusari.albumID))")
    }

    func add(_ kusari: PKTKusari<PKTListenItem>, userInfo: [AnyHashable: Any] = [:]) {
        // TODO: Implement add
        Log.debug("Add listen album: \(String(describing: kusari.albumID))")
    }

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
