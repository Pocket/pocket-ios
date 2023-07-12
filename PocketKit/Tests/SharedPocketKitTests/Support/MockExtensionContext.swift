// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

class MockExtensionContext: ExtensionContext {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    let extensionItems: [ExtensionItem]

    init(extensionItems: [ExtensionItem]) {
        self.extensionItems = extensionItems
    }
}

extension MockExtensionContext {
    static let completeRequestImpl = "completeRequestImpl"

    typealias CompleteRequestImpl = ([Any]?, ((Bool) -> Void)?) -> Void

    func stubCompleteRequest(_ impl: @escaping CompleteRequestImpl) {
        implementations[Self.completeRequestImpl] = impl
    }

    func completeRequest(returningItems items: [Any]?, completionHandler: ((Bool) -> Void)?) {
        guard let impl = implementations[Self.completeRequestImpl] as? CompleteRequestImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        impl(items, completionHandler)
    }
}

class MockExtensionItem: ExtensionItem {
    let itemProviders: [ItemProvider]?

    init(itemProviders: [ItemProvider]?) {
        self.itemProviders = itemProviders
    }
}

class MockItemProvider: ItemProvider {
    private var implementations: [String: Any] = [:]
}

extension MockItemProvider {
    static let hasItemImpl = "hasItemImpl"

    typealias HasItemImpl = (String) -> Bool

    func stubHasItemConformingToTypeIdentifier(_ impl: @escaping HasItemImpl) {
        implementations[Self.hasItemImpl] = impl
    }

    func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
        guard let impl = implementations[Self.hasItemImpl] as? HasItemImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        return impl(typeIdentifier)
    }
}

extension MockItemProvider {
    static let loadItemImpl = "loadItemImpl"

    typealias LoadItemImpl = (String, [AnyHashable: Any]?) async throws -> NSSecureCoding

    func stubLoadItem(_ impl: @escaping LoadItemImpl) {
        implementations[Self.loadItemImpl] = impl
    }

    func loadItem(forTypeIdentifier typeIdentifier: String, options: [AnyHashable: Any]?) async throws -> NSSecureCoding {
        guard let loadItemImpl = implementations[Self.loadItemImpl] as? LoadItemImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        return try await loadItemImpl(typeIdentifier, options)
    }
}
