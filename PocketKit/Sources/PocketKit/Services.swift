// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation


struct Services {
    static let shared = Services()

    let keychain: Keychain
    let accessTokenStore: AccessTokenStore
    let urlSession: URLSessionProtocol
    let authClient: AuthorizationClient
    let source: Source

    private init() {
        keychain = SecItemKeychain()
        accessTokenStore = KeychainAccessTokenStore(keychain: keychain)

        urlSession = URLSession.shared
        authClient = AuthorizationClient(
            consumerKey: Keys.shared.pocketApiConsumerKey,
            session: urlSession
        )

        source = Source(
            accessTokenProvider: accessTokenStore,
            consumerKey: Keys.shared.pocketApiConsumerKey
        )
    }
}
