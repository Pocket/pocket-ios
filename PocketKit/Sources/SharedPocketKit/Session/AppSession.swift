// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class AppSession {
    @KeychainStorage public var currentSession: Session?

    public init(keychain: Keychain = SecItemKeychain(), groupID: String) {
        _currentSession = KeychainStorage(keychain: keychain, account: "session", groupID: groupID)
    }
}
