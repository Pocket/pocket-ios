// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class AppSession: ObservableObject {
    @KeychainStorage private var storedSession: Session?
    @Published public private(set) var currentSession: Session?

    public init(keychain: Keychain = SecItemKeychain(), groupID: String) {
        _storedSession = KeychainStorage(keychain: keychain, account: "session", groupID: groupID)
        currentSession = storedSession
    }

    /// Clear the current session from memory and keychain
    public func clearCurrentSession() {
        currentSession = nil
        storedSession = nil
    }

    /// Sets the current session to `anonymous`
    /// - Parameter guid: the anonymous session guid retrieved from the backend
    public func setAnonymousSession(_ guid: String) {
        setCurrentSession(.anonymous(guid))
    }

    /// Set the current session to the passed session, both in memory and in the keychain
    /// - Parameter session: the passed session object
    public func setCurrentSession(_ session: Session) {
        currentSession = session
        storedSession = session
    }
}
