//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/25/23.
//

import Foundation
import Sync

extension Item {
    func wordEstimation() -> Int {
        if let wordCount, wordCount.intValue > 0 {
            return wordCount.intValue
        }
        if let timeToRead, timeToRead.intValue > 0 {
            return timeToRead.intValue
        }
        return 0
    }
}
