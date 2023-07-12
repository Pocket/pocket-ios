// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

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
