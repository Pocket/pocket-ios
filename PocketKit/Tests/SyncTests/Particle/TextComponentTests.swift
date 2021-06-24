// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync

class TextComponentTests: XCTestCase {
    func test_decode_decodesEachTypeOfModifier() throws {
        let textComponent: TextContent = Fixture.decode(name: "particle/text-modifiers")
        XCTAssertEqual(
            textComponent.modifiers?[0],
            .link(
                InlineLink(
                    start: 0,
                    length: 4,
                    address: URL(string: "http://example.com/inline-link")!
                )
            )
        )

        let expectedStyles = InlineStyle.Style.allCases
        for (index, expectedStyle) in expectedStyles.enumerated() {
            // offset by 1 to account for link as first element
            let offsetIndex = index + 1
            guard let modifier = textComponent.modifiers?[offsetIndex] else {
                XCTFail("Expected modifiers to be populated but it was nil")
                return
            }

            guard case .style(let actualStyle) = modifier else {
                XCTFail("Expected style modifier, got: \(modifier)")
                return
            }

            XCTAssertEqual(expectedStyle, actualStyle.style)
        }
    }
}
