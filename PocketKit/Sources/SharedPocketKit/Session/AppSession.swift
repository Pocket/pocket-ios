import Foundation

public class AppSession {
    @KeychainStorage
    public var currentSession: Session?

    public init(keychain: Keychain = SecItemKeychain(), groupId: String) {
        _currentSession = KeychainStorage(keychain: keychain, account: "session", groupId: groupId)
    }
}
