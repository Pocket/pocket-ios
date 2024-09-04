// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
public class FeatureFlag {
    var assigned: Bool
    var name: String
    var payloadValue: String?
    var variant: String?
    public init(assigned: Bool, name: String) {
        self.assigned = assigned
        self.name = name
    }
}
