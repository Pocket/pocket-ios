// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class SlateLineup {
    var experimentID: String
    var remoteID: String
    var requestID: String
    @Relationship(deleteRule: .cascade, inverse: \Slate.slateLineup)
    var slates: [Slate]?
    public init(experimentID: String, remoteID: String, requestID: String) {
        self.experimentID = experimentID
        self.remoteID = remoteID
        self.requestID = requestID
    }

// #warning("The property \"ordered\" on SlateLineup:slates is unsupported in SwiftData.")
}
