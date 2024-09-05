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
@objc(ArticleTransformer)
class ArticleTransformer: ValueTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: ArticleTransformer.self))

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

        return try? JSONEncoder().encode(article) as NSData
    }

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    public static func register() {
        let transformer = ArticleTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
