//
//  LoggedOut.swift
//
//
//  Created by Daniel Brooks on 2/10/23.
//

import Foundation

public extension Events {
    struct LoggedOut {}
}

public extension Events.LoggedOut {
    /**
     Called after login, before authorization
     */
    static func LoggedIn() -> Event {
        // TODO: Use right identifier
        return Engagement(
            uiEntity: UiEntity(.button, identifier: "logged.in")
        )
    }

    /**
     Called after sign up, before authorization
     */
    static func SignedUp() -> Event {
        // TODO: Use right identifier
        return Engagement(
            uiEntity: UiEntity(.button, identifier: "signed.up")
        )
    }
}
