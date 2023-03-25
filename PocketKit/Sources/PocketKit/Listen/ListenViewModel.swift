//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/24/23.
//

import Foundation
import Sync
import PKTListen

class ListenViewModel: NSObject {
    let savedItems: [SavedItem]?

    init(savedItems: [SavedItem]?) {
        self.savedItems = savedItems
    }
}
