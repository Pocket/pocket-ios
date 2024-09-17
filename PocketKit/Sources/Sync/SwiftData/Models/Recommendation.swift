// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Recommendation {
    // #Unique<Recommendation>([\.remoteID])
    public var analyticsID: String
    public var excerpt: String?
    public var imageURL: URL?
    public var remoteID: String
    public var sortIndex: Int16 = 0
    public var title: String?
    public var image: Image?
    public var item: Item?
    public var slate: Slate?
    public init(analyticsID: String, remoteID: String) {
        self.analyticsID = analyticsID
        self.remoteID = remoteID
    }
}
