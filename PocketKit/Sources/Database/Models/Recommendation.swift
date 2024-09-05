// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Recommendation {
    // ios 18 only - #Unique<Recommendation>([\.remoteID])
    var analyticsID: String
    var excerpt: String?
    var imageURL: URL?
    var remoteID: String
    var sortIndex: Int16? = 0
    var title: String?
    var image: Image?
    var item: Item?
    var slate: Slate?
    public init(analyticsID: String, remoteID: String) {
        self.analyticsID = analyticsID
        self.remoteID = remoteID
    }
}
