// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync

class ArticleTests: XCTestCase {
    func test_decode_whenContentIsEmptyArray_createsEmptyArticle() {
        let article: Article = Fixture.decode(name: "particle/empty")
        XCTAssertEqual(article.content, [])
    }
}
