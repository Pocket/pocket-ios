import Foundation

extension String {
    func localized(withComment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle(for: HomeTests.self), value: "Localizable string not found!", comment: withComment)
    }
}
