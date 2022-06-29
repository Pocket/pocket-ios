import Sync
import Analytics
import Textile
import Foundation
import SharedPocketKit


class AccountViewModel {
    private let appSession: AppSession

    init(appSession: AppSession) {
        self.appSession = appSession
    }

    func signOut() {
        appSession.currentSession = nil
    }
}
