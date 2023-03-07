// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

struct PremiumUpgradeViewElement: PocketUIElement {
    var element: XCUIElement

    init(_ element: XCUIElement) {
        self.element = element
    }

    var premiumUpgradeMonthlyButton: XCUIElement {
        element.buttons["premium-upgrade-view-monthly-button"]
    }

    var premiumUpgradeAnnualButton: XCUIElement {
        element.buttons["premium-upgrade-view-annual-button"]
    }

    var dismissPremiumButton: XCUIElement {
        element.buttons["premium-upgrade-view-dismiss-button"]
    }
}
