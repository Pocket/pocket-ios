import Foundation
import Sync
import SharedPocketKit


class SignOutOnFirstLaunch {
    static let hasAppBeenLaunchedPreviouslyKey = "hasAppBeenLaunchedPreviously"

    private let appSession: AppSession
    private let userDefaults: UserDefaults

    init(
        appSession: AppSession,
        userDefaults: UserDefaults
    ) {
        self.appSession = appSession
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

        appSession.currentSession = nil
        hasAppBeenLaunchedPreviously = true
    }
}
