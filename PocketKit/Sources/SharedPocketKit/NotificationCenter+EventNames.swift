import Foundation

public extension Notification.Name {
    static let userLoggedIn = Notification.Name("com.mozilla.pocket.userLoggedIn")
    static let userLoggedOut = Notification.Name("com.mozilla.pocket.userLoggedOut")
    static let listUpdated = Notification.Name("com.mozilla.pocket.listUpdated")
    static let bannerRequested = Notification.Name("com.mozilla.pocket.bannerRequested")
}
