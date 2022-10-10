import Sync
import Analytics
import Textile
import Foundation
import SharedPocketKit
import SwiftUI

class AccountViewModel: ObservableObject {
    private let appSession: AppSession

    init(appSession: AppSession) {
        self.appSession = appSession
    }

    func signOut() {
        // Post that we logged out to the rest of the app using the old session
        NotificationCenter.default.post(name: .userLoggedOut, object: appSession.currentSession)
        appSession.currentSession = nil
    }

    @Published var isPresentingHelp = false
    @Published var isPresentingTerms = false
    @Published var isPresentingPrivacy = false
    @Published var isPresentingSignOutConfirm = false
}
