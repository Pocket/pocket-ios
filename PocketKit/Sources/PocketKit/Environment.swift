// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync


private struct AccessTokenStoreKey: EnvironmentKey {
    static var defaultValue: AccessTokenStore = Services.shared.accessTokenStore
}

private struct AuthorizationClientKey: EnvironmentKey {
    static var defaultValue: AuthorizationClient = Services.shared.authClient
}

private struct SourceKey: EnvironmentKey {
    static var defaultValue = Services.shared.source
}

private struct CharacterDirectionKey: EnvironmentKey {
    static var defaultValue: LayoutDirection = .leftToRight
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

    var source: Source {
        get { self[SourceKey.self] }
        set { self[SourceKey.self] = newValue }
    }
    
    var characterDirection: LayoutDirection {
        get { self[CharacterDirectionKey.self] }
        set { self[CharacterDirectionKey.self] = newValue }
    }
}
