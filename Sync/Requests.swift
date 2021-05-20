// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData


public enum Requests {
    public static func fetchItems() -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.timestamp, ascending: false),
            NSSortDescriptor(keyPath: \Item.title, ascending: true)
        ]
        return request
    }
    
    public static func fetchItem(byURL url: String) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", url)
        request.fetchLimit = 1
        return request
    }
}
