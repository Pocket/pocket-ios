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
protocol AppEvent {
    var event: Event { get }
    var entities: [Entity] { get }
}
