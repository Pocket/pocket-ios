// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Tag {
    // #Unique<Tag>([\.name])
    public var name: String
    public var remoteID: String?
    public var savedItems: [SavedItem]?
    public init(name: String) {
        self.name = name
    }

// #warning("The property \"ordered\" on Tag:savedItems is unsupported in SwiftData.")

}
