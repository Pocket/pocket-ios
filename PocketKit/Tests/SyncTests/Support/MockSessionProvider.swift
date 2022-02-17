import Sync

class MockSessionProvider: SessionProvider {
    var session: Session?

    init(session: Session?) {
        self.session = session
    }
}

struct MockSession: Session {
    let guid = "session-guid"
    let accessToken = "session-access-token"
}
