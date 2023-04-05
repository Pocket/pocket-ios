// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct SettingsViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var logOutButton: XCUIElement {
        element.buttons["log-out-button"].wait()
    }

    var accountManagementButton: XCUIElement {
        element.buttons["account-management-button"].wait()
    }

    var goPremiumButton: XCUIElement {
        element.buttons["go-premium-button"].wait()
    }

    var premiumSubscriptionButton: XCUIElement {
        element.buttons["premium-subscription-button"].wait()
    }
}
