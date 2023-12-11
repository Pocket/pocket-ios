// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
public extension Events {
    struct Listen {
        /// Describes whether Listen was controlled via the app or via the apple system (bluetooth, car, etc)
        public enum ControlType: String {
            case inapp
            case system
        }
    }
}

public extension Events.Listen {
    /// Fired when an Item is impressed in the listen view
    /// - Parameters:
    ///   - url: URL of the item
    ///   - positionInList: Index of the item in the list
    /// - Returns: Impression event
    static func ItemImpression(url: String, positionInList: Int) -> Impression {
        return Impression(
            component: .card,
            requirement: .viewable,
            uiEntity: UiEntity(
                .card,
                identifier: "listen.list.impression",
                index: positionInList
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /// Fired when a User starts playback of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback started
    /// - Returns: Engagement event
    static func StartPlayback(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.start",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User resumes playback of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback resumed
    /// - Returns: Engagement event
    static func ResumePlayback(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.resume",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User pauses playback of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback paused
    /// - Returns: Engagement event
    static func PausePlayback(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.pause",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User fast forwards an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback fast forwarded
    /// - Returns: Engagement event
    static func FastForward(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.fast_forward",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User rewinds an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback rewound
    /// - Returns: Engagement event
    static func Rewind(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.rewind",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User skip next an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback skipped forward
    /// - Returns: Engagement event
    static func SkipNext(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.skip_next",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User skips back an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback skipped backward
    /// - Returns: Engagement event
    static func SkipBack(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.skip_back",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User sets the speed of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback skipped backward
    ///   - speed: The speed of the playback
    /// - Returns: Engagement event
    static func SetSpeed(url: String, controlType: ControlType, speed: Double) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.set_speed",
                componentDetail: controlType.rawValue,
                value: String(speed)
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User finishes the playback of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback was finished
    /// - Returns: Engagement event
    static func FinsihedListen(url: String, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.finished",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
            ]
        )
    }

    /// Fired when a User opens listen with the item it was opened to
    /// - Parameters:
    ///   - controlType: How the playback was finished
    /// - Returns: Engagement event
    static func Opened() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.opened"
            )
        )
    }

    /// Fired when a User closes listen
    /// - Returns: Engagement event
    static func Closed() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.closed"
            )
        )
    }

    /// Fired when a user collapses the player into mini mode
    /// - Returns: Engagement event
    static func Collapsed() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.player.collapsed"
            )
        )
    }

    /// Fired when a user closes the mini player
    /// - Returns: Engagement event
    static func MiniClosed() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.player.mini.close"
            )
        )
    }

    /// Fired when a user expands the mini player
    /// - Returns: Engagement event
    static func Expanded() -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.player.expanded"
            )
        )
    }

    /// Fired when a user archives an article via listen
    /// - Parameters:
    ///   - url: URL of the item
    ///   - position: Position in the list
    /// - Returns: Engagement event
    static func Archived(url: String, position: Int) -> Engagement {
        return Engagement(
            uiEntity: UiEntity(
                .button,
                identifier: "listen.archive",
                index: position
            ),
            extraEntities: [
                ContentEntity(url: url)
            ]
        )
    }

    /// Fired when a user moves an item from archive to saves via listen
    /// - Parameters:
    ///   - url: URL of the item
    ///   - position: Position in the list
    /// - Returns: Engagement event
    static func MoveFromArchiveToSaves(url: String, position: Int) -> Engagement {
        return Engagement(
            .save(contentEntity: ContentEntity(url: url)),
            uiEntity: UiEntity(
                .button,
                identifier: "listen.un-archive",
                index: position
            )
        )
    }
}
