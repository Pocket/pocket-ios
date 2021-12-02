import Foundation
import Sync


class SignOutOnFirstLaunch {
    static let hasAppBeenLaunchedPreviouslyKey = "hasAppBeenLaunchedPreviously"

    private let sessionController: SessionController
    private let userDefaults: UserDefaults

    init(
        sessionController: SessionController,
        userDefaults: UserDefaults
    ) {
        self.sessionController = sessionController
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

        sessionController.clearAccessToken()
        hasAppBeenLaunchedPreviously = true
    }
}
