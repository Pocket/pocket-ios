// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SwiftUI


struct StaticDataCleaner {
    static let hasClearedStaticDataKey = "StatisDataCleaner.hasClearedStaticData"
    private let bundle: Bundle
    private let source: Source

    @AppStorage
    private var hasClearedStaticData: Bool

    init(bundle: Bundle, source: Source, userDefaults: UserDefaults) {
        self.bundle = bundle
        self.source = source
        
        _hasClearedStaticData = AppStorage(
            wrappedValue: false,
            Self.hasClearedStaticDataKey,
            store: userDefaults
        )
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
