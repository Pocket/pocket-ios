//
//  Event.swift
//
//
//  Created by Daniel Brooks on 2/10/23.
//
import Foundation
import class SnowplowTracker.SelfDescribing

/**
 * A snowplow event
 */
public protocol Event {
    func toSelfDescribing() -> SelfDescribing
}
