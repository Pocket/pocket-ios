// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

@main
struct PocketApp: App {
    @State var authResponse: AuthorizeResponse?
    private let authClient = AuthorizationClient(
        consumerKey: Bundle.main.infoDictionary!["PocketAPIConsumerKey"] as! String,
        session: URLSession.shared
    )

    @ViewBuilder
    var body: some Scene {
        WindowGroup {
            if let account = authResponse?.account {
                LoggedInView(account: account)
            } else {
                SignInView(
                    authClient: authClient,
                    authResponse: $authResponse
                )
            }
        }
    }
}
