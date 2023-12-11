// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync

class MockSessionProvider: SessionProvider {
    var session: Session?

    init(session: Session?) {
        self.session = session
    }
}

struct MockSession: Session {
    var guid = "session-guid"
    var accessToken = "session-access-token"
}
