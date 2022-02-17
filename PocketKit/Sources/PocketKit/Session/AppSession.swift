import Foundation

class AppSession {
    @KeychainStorage(keychain: SecItemKeychain(), service: Bundle.main.bundleIdentifier!, account: "session")
    var currentSession: Session?
}
