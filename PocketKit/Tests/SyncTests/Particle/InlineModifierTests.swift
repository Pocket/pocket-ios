// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync


class InlineModiferTests: XCTestCase {
    func test_decode_whenTypeIsNotRecognized_createsUnsupportedModifer() {
        let modifier: InlineModifier = Fixture.decode(name: "particle/unsupported-inline-modifier")
        XCTAssertEqual(modifier, .unsupported("something-we-dont-recognize"))
    }
}
