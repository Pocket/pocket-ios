// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync
@testable import Pocket

class RemoteImageLoaderTests: XCTestCase {
    func test_init_makesCorrectHTTPCall() {
        let url = URL(string: "https://getpocket.com")!
        
        let task = MockURLSessionDataTask()
        let session = MockURLSession()
        session.stubDataTaskWithCompletion { (request, completion) in
            return task
        }

        _ = RemoteImageLoader(url: url, session: session)
        XCTAssertFalse(session.dataTaskCalls.isEmpty)
        XCTAssertEqual(session.dataTaskCalls[0].request.url, url)
    }
}
