import Foundation


public class Article: NSObject, Codable {
    public static var supportsSecureCoding: Bool = true

    public let components: [ArticleComponent]

    init(components: [ArticleComponent]) {
        self.components = components
    }
}

class ArticleTransformer: NSSecureUnarchiveFromDataTransformer {
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
    static let articleTransfomer = NSValueTransformerName(rawValue: "ArticleTransformer")
}
