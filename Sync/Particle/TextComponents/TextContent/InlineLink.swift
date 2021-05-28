// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct InlineLink: Decodable, Equatable {
    public let start: Int
    public let length: Int
    public let address: URL

    public init(start: Int, length: Int, address: URL) {
        self.start = start
        self.length = length
        self.address = address
    }
}
