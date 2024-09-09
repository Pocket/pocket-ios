// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@Model
public class Author {
    public var id: String
    public var name: String?
    public var url: URL?
    @Relationship(inverse: \Item.authors)
    public var item: Item?
    public init(id: String) {
        self.id = id
    }
}
