import Foundation

protocol ExtensionContext {
    var extensionItems: [ExtensionItem] { get }

    func completeRequest(returningItems items: [Any]?, completionHandler: ((Bool) -> Void)?)
}
extension NSExtensionContext: ExtensionContext {
    var extensionItems: [ExtensionItem] {
        inputItems.compactMap { $0 as? ExtensionItem }
    }
}

protocol ExtensionItem {
    var itemProviders: [ItemProvider]? { get }
}
extension NSExtensionItem: ExtensionItem {
    var itemProviders: [ItemProvider]? {
        attachments?.compactMap { $0 as ItemProvider }
    }
}

protocol ItemProvider {
    func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool

    func loadItem(
        forTypeIdentifier typeIdentifier: String,
        options: [AnyHashable: Any]?
    ) async throws -> NSSecureCoding
}
extension NSItemProvider: ItemProvider { }
