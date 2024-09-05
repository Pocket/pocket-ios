// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph

extension CDDomainMetadata {
    func update(remote: DomainMetadataParts) {
        name = remote.name
        logo = remote.logo.flatMap(URL.init(string:))
    }
}
