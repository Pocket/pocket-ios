// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import PocketGraph

extension CDFeatureFlag {
    func update(from remote: RemoteFeatureFlagAssignment) {
        name = remote.name
        assigned = remote.assigned
        variant = remote.variant
        payloadValue = remote.payload
    }
}
