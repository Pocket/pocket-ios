// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

@main
struct AppClipExtensionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
                    guard let url = userActivity.webpageURL else {
                        // Figure out how to error out?
                        return
                    }
                    // URL passed to the app clip
                    // This could be any url from getpocket.com, pocket.co that is supported by our LinkRouter
                    // TODO:
                    //    At this point we should
                    //      Open the native view for this content. (Syndication, Collection, or the Share/Read link)
                    //          At the right moment, present the StoreKit get the app overlay.
                    
            })
        }
    }
}
