// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct ReportIssueViewElement: PocketUIElement {
    let element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var nameField: XCUIElement {
        element.textFields["name-field"]
    }

    var emailField: XCUIElement {
        element.textFields["email-field"]
    }

    var commentSection: XCUIElement {
        element.textViews["comment-section"]
    }

    var submitButton: XCUIElement {
        element.buttons["submit-issue"]
    }
}
