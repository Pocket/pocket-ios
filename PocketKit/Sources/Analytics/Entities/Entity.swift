//
//  Entity.swift
//
//
//  Created by Daniel Brooks on 2/10/23.
//
import class SnowplowTracker.SelfDescribingJson

/**
 * A snowplow entity or context
 */
public protocol Entity {
    func toSelfDescribingJson() -> SelfDescribingJson
}
