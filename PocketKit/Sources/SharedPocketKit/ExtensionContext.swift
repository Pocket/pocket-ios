// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public protocol ExtensionContext {
    var extensionItems: [ExtensionItem] { get }

    func completeRequest(returningItems items: [Any]?, completionHandler: ((Bool) -> Void)?)
}

extension NSExtensionContext: ExtensionContext {
    public var extensionItems: [ExtensionItem] {
        inputItems.compactMap { $0 as? ExtensionItem }
    }
}

public protocol ExtensionItem {
    var itemProviders: [ItemProvider]? { get }
}

extension NSExtensionItem: ExtensionItem {
    public var itemProviders: [ItemProvider]? {
        attachments?.compactMap { $0 as ItemProvider }
    }
}
