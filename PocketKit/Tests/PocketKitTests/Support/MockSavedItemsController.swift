// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation

class MockSavedItemsController: SavedItemsController {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    weak var delegate: SavedItemsControllerDelegate?

    var predicate: NSPredicate?

    var fetchedObjects: [SavedItem]?

    var sortDescriptors: [NSSortDescriptor]?
}

extension MockSavedItemsController {
    static let performFetch = "performFetch"
    typealias PerformFetchImpl = () -> Void
    struct PerformFetchCall { }

    func stubPerformFetch(impl: @escaping PerformFetchImpl) {
        implementations[Self.performFetch] = impl
    }

    func performFetch() throws {
        guard let impl = implementations[Self.performFetch] as? PerformFetchImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.performFetch] = (calls[Self.performFetch] ?? []) + [PerformFetchCall()]

        impl()
    }

    func performFetchCall(at index: Int) -> PerformFetchCall? {
        guard let calls = calls[Self.performFetch], calls.count > index else {
            return nil
        }

        return calls[index] as? PerformFetchCall
    }
}

extension MockSavedItemsController {
    static let indexPathForObject = "indexPathForObject"
    typealias IndexPathForObjectImpl = (SavedItem) -> IndexPath?
    struct IndexPathForObjectCall {
        let savedItem: SavedItem
    }

    func stubIndexPathForObject(impl: @escaping IndexPathForObjectImpl) {
        implementations[Self.indexPathForObject] = impl
    }

    func indexPath(forObject savedItem: SavedItem) -> IndexPath? {
        guard let impl = implementations[Self.indexPathForObject] as? IndexPathForObjectImpl else {
            fatalError("\(Self.self).\(#function) has not been implemented")
        }

        calls[Self.indexPathForObject] = (calls[Self.indexPathForObject] ?? []) + [
            IndexPathForObjectCall(savedItem: savedItem)
        ]

        return impl(savedItem)
    }
}
