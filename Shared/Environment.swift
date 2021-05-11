// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI


private struct AccessTokenStoreKey: EnvironmentKey {
    static var defaultValue: AccessTokenStore = AccessTokenStore(
        keychain: SecItemKeychain()
    )
}

private struct AuthorizationClientKey: EnvironmentKey {
    static var defaultValue: AuthorizationClient = AuthorizationClient(
        consumerKey: Bundle.main.infoDictionary!["PocketAPIConsumerKey"] as! String,
        session: URLSession.shared
    )
}

extension EnvironmentValues {
    var accessTokenStore: AccessTokenStore {
        get { self[AccessTokenStoreKey.self] }
        set { self[AccessTokenStoreKey.self] = newValue }
    }

    var authorizationClient: AuthorizationClient {
        get { self[AuthorizationClientKey.self] }
        set { self[AuthorizationClientKey.self] = newValue }
    }
}
