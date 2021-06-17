// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SwiftUI


struct StaticDataCleaner {
    private let bundle: Bundle
    private let source: Source

    @AppStorage("hasClearedStaticData")
    private var hasClearedStaticData: Bool = false

    init(bundle: Bundle, source: Source) {
        self.bundle = bundle
        self.source = source
    }

    private var currentBuildNumber: Int? {
        guard let buildNumberString = bundle.infoDictionary?["CFBundleVersion"] as? String,
              let buildNumber = Int(buildNumberString) else {
            return nil
        }

        return buildNumber
    }

    func clearIfNecessary() {
        guard let buildNumber = currentBuildNumber else {
            return
        }

        if buildNumber <= 70, !hasClearedStaticData {
            source.clear()
            hasClearedStaticData = true
        }
    }
}
