// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

extension XCUIElement {
    @discardableResult
    func wait(
        timeout: TimeInterval = 3,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCUIElement {
        if exists {
            return self
        }

        let cameIntoExistence = waitForExistence(timeout: timeout)
        if cameIntoExistence {
            return self
        } else {
            XCTFail("Expected \(self) to exist but it was not found.", file: file, line: line)
        }

        return self
    }

    @discardableResult
    func verify() -> XCUIElement {
        XCTAssertTrue(exists)
        return self
    }
}
