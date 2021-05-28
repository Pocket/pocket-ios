// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync


class InlineStyleTests: XCTestCase {
    func test_decode_whenStyleIsUnrecognized_createsUnsupportedStyle() {
        let style: InlineStyle = Fixture.decode(name: "particle/unsupported-style")
        XCTAssertEqual(style.style, .unsupported("something-unrecognized"))
    }
}
