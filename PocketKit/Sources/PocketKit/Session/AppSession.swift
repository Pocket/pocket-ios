import Foundation

class AppSession {
    @KeychainStorage(account: "session")
    var currentSession: Session?
}
