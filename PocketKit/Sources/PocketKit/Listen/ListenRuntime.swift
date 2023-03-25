// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Combine
import PKTListen

class ListenRuntime: NSObject {
    private var subscriptions: Set<AnyCancellable> = []

    static let colors = PKTListenAppTheme()

    init(appSession: AppSession) {
        super.init()
        PKTLocalRuntime.shared().start()
        PKTListen.sharedInstance().sessionDelegate = self

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
       // TODO: Wipe session
       // HOW?
    }
}

extension ListenRuntime: PKTListenServiceDelegate {
    func postAction(_ actionName: String, kusari: PKTKusari<PKTListenItem>?, data userInfo: [AnyHashable: Any]) {
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
