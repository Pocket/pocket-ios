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
