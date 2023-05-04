// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

struct Keys {
    static let shared = Keys()

    let pocketApiConsumerKey: String
    let sentryDSN: String
    let groupID: String
    let brazeAPIEndpoint: String
    let brazeAPIKey: String

    private init() {
        guard let info = Bundle.main.infoDictionary else {
            fatalError("Unable to load info dictionary for main bundle")
        }

        guard let pocketApiConsumerKey = info["PocketAPIConsumerKey"] as? String else {
            fatalError("Unable to extract PocketApiConsumerKey from main bundle")
        }

        guard let pocketApiConsumerKeyPad = info["PocketAPIConsumerKeyPad"] as? String else {
            fatalError("Unable to extract PocketApiConsumerKeyPad from main bundle")
        }

        guard let sentryDSN = info["SentryDSN"] as? String else {
            fatalError("Unable to extract SentryDSN from main bundle")
        }

        guard let groupID = info["GroupId"] as? String else {
            fatalError("Unable to extract GroupId from main bundle")
        }

        guard let brazeAPIEndpoint = info["BrazeAPIEndpoint"] as? String else {
            fatalError("Unable to extract BrazeAPIEndpoint from main bundle")
        }

        guard let brazeAPIKey = info["BrazeAPIKey"] as? String else {
            fatalError("Unable to extract BrazeAPIKey from main bundle")
        }

        self.pocketApiConsumerKey = UIDevice.current.userInterfaceIdiom == .pad ? pocketApiConsumerKeyPad : pocketApiConsumerKey
        self.sentryDSN = sentryDSN
        self.groupID = groupID
        self.brazeAPIEndpoint = brazeAPIEndpoint
        self.brazeAPIKey = brazeAPIKey
    }
}
