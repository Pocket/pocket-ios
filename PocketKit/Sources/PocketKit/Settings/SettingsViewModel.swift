import Sync
import Analytics
import Textile
import Foundation


class SettingsViewModel {
    private let appSession: AppSession

    init(appSession: AppSession) {
        self.appSession = appSession
    }

    func signOut() {
        appSession.currentSession = nil
    }
}
