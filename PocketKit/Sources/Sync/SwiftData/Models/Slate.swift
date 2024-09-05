// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Slate {
    var experimentID: String
    var name: String?
    var remoteID: String
    var requestID: String
    var slateDescription: String?
    var sortIndex: Int16? = 0
    @Relationship(deleteRule: .cascade)
    var recommendations: [Recommendation]?
    var slateLineup: SlateLineup?
    public init(experimentID: String, remoteID: String, requestID: String) {
        self.experimentID = experimentID
        self.remoteID = remoteID
        self.requestID = requestID
    }

// #warning("The property \"ordered\" on Slate:recommendations is unsupported in SwiftData.")
}
