import Foundation

public class SignOutOnFirstLaunch {
    static let hasAppBeenLaunchedPreviouslyKey = UserDefaults.Key.hasAppBeenLaunchedPreviously

    private let appSession: AppSession
    private let user: User
    private let userDefaults: UserDefaults

    public init(
        appSession: AppSession,
        user: User,
        userDefaults: UserDefaults
    ) {
        self.appSession = appSession
        self.user = user
        self.userDefaults = userDefaults
    }

    private var hasAppBeenLaunchedPreviously: Bool {
        get {
            userDefaults.bool(forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.hasAppBeenLaunchedPreviouslyKey)
        }
    }

    public func signOutOnFirstLaunch() {
        guard !hasAppBeenLaunchedPreviously else {
            return
        }

        user.clear()
        appSession.currentSession = nil
        hasAppBeenLaunchedPreviously = true
    }
}
