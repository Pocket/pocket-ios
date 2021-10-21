import Foundation


public class Article: NSObject, NSSecureCoding, Codable {
    public static var supportsSecureCoding: Bool = true

    public func encode(with coder: NSCoder) {
        guard let data = try? JSONEncoder().encode(self) else {
            return
        }

        coder.encode(data, forKey: "components")
    }

    public required init?(coder: NSCoder) {
        guard let data = coder.decodeObject(forKey: "components") as? Data,
              let components = try? JSONDecoder().decode([ArticleComponent].self, from: data) else {
            return nil
        }

        self.components = components
    }

    public let components: [ArticleComponent]

    init(components: [ArticleComponent]) {
        self.components = components
    }
}
