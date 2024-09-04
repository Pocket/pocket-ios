// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@available(iOS 17, *)
@Model
public class DomainMetadata {
    var logo: URL?
    var name: String?
    @Relationship(inverse: \Item.domainMetadata)
    var item: Item?
    public init() {
    }
}
