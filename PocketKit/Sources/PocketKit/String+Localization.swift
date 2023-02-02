import Foundation

extension String {
    func localized(withComment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: .module, value: "Localizable string not found!", comment: withComment)
    }

    func localized(_ withArguments: CVarArg..., comment: String = "") -> String {
        return String.localizedStringWithFormat(localized(withComment: comment), withArguments)
    }
}
