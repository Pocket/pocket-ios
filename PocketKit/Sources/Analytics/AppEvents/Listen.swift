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
    static func ItemImpression(url: URL, positionInList: Int) -> Impression {
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
    static func StartPlayback(url: URL, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.start",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
                // MediaPlayerEntity(currentTime: <#T##TimeInterval#>, duration: <#T##TimeInterval#>, ended: <#T##Bool#>, loop: <#T##Bool#>, muted: <#T##Bool#>, paused: <#T##Bool#>, playbackRate: <#T##Double#>, volume: <#T##Int#>)
            ]
        )
    }
    
    /// Fired when a User resumes playback of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback resumed
    /// - Returns: Engagement event
    static func ResumePlayback(url: URL, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.resume",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
                // MediaPlayerEntity(currentTime: <#T##TimeInterval#>, duration: <#T##TimeInterval#>, ended: <#T##Bool#>, loop: <#T##Bool#>, muted: <#T##Bool#>, paused: <#T##Bool#>, playbackRate: <#T##Double#>, volume: <#T##Int#>)
            ]
        )
    }
    
    /// Fired when a User pauses playback of an item
    /// - Parameters:
    ///   - url: URL of the item
    ///   - controlType: How the playback resumed
    /// - Returns: Engagement event
    static func PausePlayback(url: URL, controlType: ControlType) -> Engagement {
        return Engagement(
            .general,
            uiEntity: UiEntity(
                .button,
                identifier: "listen.playback.pause",
                componentDetail: controlType.rawValue
            ),
            extraEntities: [
                ContentEntity(url: url),
                // MediaPlayerEntity(currentTime: <#T##TimeInterval#>, duration: <#T##TimeInterval#>, ended: <#T##Bool#>, loop: <#T##Bool#>, muted: <#T##Bool#>, paused: <#T##Bool#>, playbackRate: <#T##Double#>, volume: <#T##Int#>)
            ]
        )
    }
}
