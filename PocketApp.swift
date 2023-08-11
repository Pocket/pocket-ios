// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketKit
import SwiftUI

@main
struct PocketApp: App {
    @UIApplicationDelegateAdaptor var delegate: PocketAppDelegate

    var body: some Scene {
        WindowGroup {
            RootView(model: RootViewModel())
                .onOpenURL { url in
                    if url.scheme == "pocket" {
                        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
                        let urlItem = queryItems?.filter {
                            $0.name == "url"
                        }

                        if url.host() == "home" {
                            // TODO: Open Item
                        } else {
                            // TODO: Log invalid deeplink
                            return
                        }
                    }
                }
        }
    }
}
