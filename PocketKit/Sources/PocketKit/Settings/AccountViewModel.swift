import Sync
import Analytics
import Textile
import Foundation
import SharedPocketKit
import SwiftUI

class AccountViewModel: ObservableObject {
    private let appSession: AppSession
    private let user: User

    init(appSession: AppSession, user: User) {
        self.appSession = appSession
        self.user = user
    }

    func signOut() {
        // Post that we logged out to the rest of the app using the old session
        NotificationCenter.default.post(name: .userLoggedOut, object: appSession.currentSession)
        user.clear()
        appSession.currentSession = nil
    }

    @Published var isPresentingHelp = false
    @Published var isPresentingTerms = false
    @Published var isPresentingPrivacy = false
    @Published var isPresentingSignOutConfirm = false
}
