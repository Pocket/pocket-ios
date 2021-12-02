import Sync
import Analytics
import Textile
import Foundation


class SettingsViewModel {
    private let sessionController: SessionController
    private let events: PocketEvents

    init(
        sessionController: SessionController,
        events: PocketEvents
    ) {
        self.sessionController = sessionController
        self.events = events
    }

    func signOut() {
        sessionController.signOut()
        events.send(.signedOut)
    }
}
