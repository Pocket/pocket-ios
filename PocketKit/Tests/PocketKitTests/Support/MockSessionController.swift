@testable import PocketKit


class MockSessionController: SessionController {
    struct UpdateCall {
        let session: Session?
    }

    var updateCalls = Calls<UpdateCall>()

    let isSignedIn: Bool

    init(isSignedIn: Bool = false) {
        self.isSignedIn = isSignedIn
    }

    func signOut() {

    }

    func updateSession(_ session: Session?) {
        updateCalls.add(UpdateCall(session: session))
    }

    func clearSession() {

    }
}
