import Foundation

public class AppSession {
    @KeychainStorage
    public var currentSession: Session?

    public init(keychain: Keychain = SecItemKeychain()) {
        _currentSession = KeychainStorage(keychain: keychain, account: "session")
    }
}
