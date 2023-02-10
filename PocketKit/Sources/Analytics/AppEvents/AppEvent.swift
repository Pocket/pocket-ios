//
//  AppEvent.swift
//  
//
//  Created by Daniel Brooks on 2/9/23.
//

import Foundation

/**
 Base app event for Pocket
 */
public class AppEvent {
    var event: Event
    var entities: [Entity]

    init(event: Event, entities: [Entity]) {
        self.event = event
        self.entities = entities
    }
}
