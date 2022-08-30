// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest


struct SortMenuElement: PocketUIElement {
    var element: XCUIElement
    
    init(_ element: XCUIElement) {
        self.element = element
    }
    
    func sortOption(_ label: String) -> XCUIElement {
        return element.cells.containing(.staticText, identifier: label).firstMatch
    }
}
