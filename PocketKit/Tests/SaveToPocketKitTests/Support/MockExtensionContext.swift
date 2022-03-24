import Foundation
@testable import SaveToPocketKit


class MockExtensionContext: ExtensionContext {
    let extensionItems: [ExtensionItem]

    init(extensionItems: [ExtensionItem]) {
        self.extensionItems = extensionItems
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

    func loadItem(forTypeIdentifier typeIdentifier: String, options: [AnyHashable : Any]?) async throws -> NSSecureCoding {
        guard let loadItemImpl = implementations[Self.loadItemImpl] as? LoadItemImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        return try await loadItemImpl(typeIdentifier, options)
    }
}
