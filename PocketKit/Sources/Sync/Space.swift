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

        self.container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func fetchItem(byURLString url: String) throws -> Item? {
        let request = Requests.fetchItem(byURLString: url)
        let result = try context.fetch(request)
        return result.first
    }
    
    func fetchOrCreateItem(byURLString url: String) throws -> Item {
        return try fetchItem(byURLString: url) ?? Item(context: context)
    }
    
    func fetchItems() throws -> [Item] {
        let request = Requests.fetchItems()
        let results = try context.fetch(request)
        
        return results
    }
    
    func save() throws {
        if Thread.isMainThread {
            try _save()
        } else {
            try DispatchQueue.main.sync {
                try _save()
            }
        }
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

private extension Space {
    func _save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
