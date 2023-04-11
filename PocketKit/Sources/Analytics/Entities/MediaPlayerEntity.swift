// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import class SnowplowTracker.SelfDescribingJson
import Foundation

/// An entity representing a media player defined by Snowplow at https://github.com/snowplow/iglu-central/blob/master/schemas/com.snowplowanalytics.snowplow/media_player/jsonschema/1-0-0
public struct MediaPlayerEntity: Entity {
    public static let schema = "iglu:com.snowplowanalytics.snowplow/media_player/jsonschema/1-0-0"

    /// The current playback time
    let currentTime: TimeInterval

    /// A double-precision floating-point value indicating the duration of the media in seconds
    let duration: TimeInterval

    /// If playback of the media has ended
    let ended: Bool

    /// If the media is live
    let isLive: Bool?

    /// If the video should restart after ending
    let loop: Bool

    /// If the media element is muted
    let muted: Bool

    /// If the media element is paused
    let paused: Bool

    /// The percent of the way through the media
    let percentProgress: Int?

    /// Playback rate (1 is normal)
    let playbackRate: Double

    /// Volume percent
    let volume: Int

    init(currentTime: TimeInterval, duration: TimeInterval, ended: Bool, isLive: Bool? = nil, loop: Bool, muted: Bool, paused: Bool, percentProgress: Int? = nil, playbackRate: Double, volume: Int) {
        self.currentTime = currentTime
        self.duration = duration
        self.ended = ended
        self.isLive = isLive
        self.loop = loop
        self.muted = muted
        self.paused = paused
        self.percentProgress = percentProgress
        self.playbackRate = playbackRate
        self.volume = volume
    }

    public func toSelfDescribingJson() -> SelfDescribingJson {
        var dict: [String: Any] =  [
            "currentTime": currentTime,
            "duration": duration,
            "ended": ended,
            "loop": loop,
            "muted": muted,
            "paused": paused,
            "playbackRate": playbackRate,
        ]

        if let isLive {
            dict["isLive"] = isLive
        }

        if let percentProgress {
            dict["percentProgress"] = percentProgress
        }

        return SelfDescribingJson(schema: MediaPlayerEntity.schema, andDictionary: dict)
    }
}
