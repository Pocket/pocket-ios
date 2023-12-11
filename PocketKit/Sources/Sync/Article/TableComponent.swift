// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PocketGraph

public struct TableComponent: Codable, Equatable, Hashable {
    public let html: String
}

extension TableComponent {
    init(_ marticle: MarticleTableParts) {
        self.init(html: marticle.html)
    }
}
