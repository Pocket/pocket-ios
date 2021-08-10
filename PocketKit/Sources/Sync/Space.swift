// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

class Space {
    private let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    required init(container: NSPersistentContainer) {
        self.container = container
    }

    func fetchItem(byURLString url: String) throws -> Item? {
        let request = Requests.fetchItem(byURLString: url)
        let result = try context.fetch(request)
        return result.first
    }

    func fetchItem(byItemID itemID: String) throws -> Item? {
        let request = Requests.fetchItem(byItemID: itemID)
        return try context.fetch(request).first
    }

    func fetchItems() throws -> [Item] {
        let request = Requests.fetchItems()
        let results = try context.fetch(request)
        return results
    }

    func fetchAllItems() throws -> [Item] {
        return try context.fetch(Requests.fetchAllItems())
    }
    
    func fetchOrCreateItem(byURLString url: String) throws -> Item {
        try fetchItem(byURLString: url) ?? newItem()
    }

    func newItem() -> Item {
        return Item(context: context)
    }

    func save() throws {
        try context.save()
    }
    
    func clear() throws {
        let context = container.viewContext
        for entity in container.managedObjectModel.entities {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name!)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
        }
    }
}
