import Foundation
import Sync
import SharedPocketKit

class SignOutOnFirstLaunch {
    static let hasAppBeenLaunchedPreviouslyKey = "hasAppBeenLaunchedPreviously"

    private let appSession: AppSession
    private let user: User
    private let userDefaults: UserDefaults

    init(
        appSession: AppSession,
        user: User,
        userDefaults: UserDefaults
    ) {
        self.appSession = appSession
        self.user = user
        self.userDefaults = userDefaults
    }

    var hasAppBeenLaunchedPreviously: Bool {
        get {
            userDefaults.bool(forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
    }

    func signOutOnFirstLaunch() {
        guard !hasAppBeenLaunchedPreviously else {
            return
        }

        user.clear()
        appSession.currentSession = nil
        hasAppBeenLaunchedPreviously = true
    }
}
