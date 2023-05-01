// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BrazeKit
import SharedPocketKit
import Sync

/**
 Class that is managing our Braze SDK implementation for the Save extension
 */
class SaveToBraze: NSObject {
    /// Our Braze SDK Object
    let braze: Braze

    init(apiKey: String, endpoint: String, groupdID: String) {
        // Init Braze with our information.
        let configuration = Braze.Configuration(
            apiKey: apiKey,
            endpoint: endpoint
        )

        // Enable logging of general SDK information (e.g. user changes, etc.)
        configuration.logger.level = .info
        configuration.push.appGroup = groupdID
        braze = Braze(configuration: configuration)

        super.init()
    }

    // MARK: Migration Events

    func signedInUserDidBeginMigration() {
        braze.logCustomEvent(name: "SIGNED_IN_USER_UPGRADE_DID_START")
    }
}
