// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

protocol PocketUIElement {
    var element: XCUIElement { get }
}

extension PocketUIElement {
    var exists: Bool {
        element.exists
    }

    var label: String {
        element.label
    }

    var frame: CGRect {
        element.frame
    }

    func tap() {
        element.tap()
    }

    @discardableResult
    func wait(
        timeout: TimeInterval = 3,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Self {
        _ = element.wait(timeout: timeout, file: file, line: line)
        return self
    }

    @discardableResult
    func verify() -> Self {
        element.verify()
        return self
    }
}
