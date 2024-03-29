// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

struct Keys {
    static let shared = Keys()

    let pocketApiConsumerKey: String
    let sentryDSN: String
    let brazeAPIEndpoint: String
    let brazeAPIKey: String
    let pocketPremiumMonthly: String
    let pocketPremiumAnnual: String
    let groupID: String
    let adjustAppToken: String
    let adjustSignUpEventToken: String

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

        guard let brazeAPIEndpoint = info["BrazeAPIEndpoint"] as? String else {
            fatalError("Unable to extract BrazeAPIEndpoint from main bundle")
        }

        guard let brazeAPIKey = info["BrazeAPIKey"] as? String else {
            fatalError("Unable to extract BrazeAPIKey from main bundle")
        }

        guard let pocketPremiumMonthly = info["PocketPremiumMonthly"] as? String else {
            fatalError("Unable to extract PocketPremiumMonthlyAlpha from main bundle")
        }

        guard let pocketPremiumAnnual = info["PocketPremiumAnnual"] as? String else {
            fatalError("Unable to extract PocketPremiumAnnualAlpha from main bundle")
        }

        guard let groupID = info["GroupId"] as? String else {
            fatalError("Unable to extract GroupID from main bundle")
        }

        guard let adjustToken = info["AdjustAppToken"] as? String else {
            fatalError("Unable to extract adjustToken from main bundle")
        }

        guard let adjustEventToken = info["AdjustSignUpEventToken"] as? String else {
            fatalError("Unable to extract adjustEventToken from main bundle")
        }

        self.pocketApiConsumerKey = UIDevice.current.userInterfaceIdiom == .pad ? pocketApiConsumerKeyPad : pocketApiConsumerKey
        self.sentryDSN = sentryDSN
        self.brazeAPIEndpoint = brazeAPIEndpoint
        self.brazeAPIKey = brazeAPIKey
        self.pocketPremiumMonthly = pocketPremiumMonthly
        self.pocketPremiumAnnual = pocketPremiumAnnual
        self.groupID = groupID
        self.adjustAppToken = adjustToken
        self.adjustSignUpEventToken = adjustEventToken
    }
}
