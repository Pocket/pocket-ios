// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public class Article: NSObject, Codable {
    public static var supportsSecureCoding: Bool = true

    public let components: [ArticleComponent]

    public init(components: [ArticleComponent]) {
        self.components = components
    }
}

public class ArticleTransformer: NSSecureUnarchiveFromDataTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(Article.self, from: data)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let article = value as? Article else {
            return nil
        }

        return try? JSONEncoder().encode(article)
    }
}

extension NSValueTransformerName {
    public static let articleTransfomer = NSValueTransformerName(rawValue: "ArticleTransformer")
}
