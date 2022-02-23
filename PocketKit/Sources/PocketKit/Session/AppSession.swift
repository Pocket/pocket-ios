import Foundation

class AppSession {
    @KeychainStorage
    var currentSession: Session?

    init(keychain: Keychain = SecItemKeychain()) {
        _currentSession = KeychainStorage(keychain: keychain, account: "session")
    }
}
