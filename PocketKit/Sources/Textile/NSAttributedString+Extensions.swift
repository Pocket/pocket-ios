import Foundation
import Down

public extension NSAttributedString {
    convenience init(string: String, style: Style) {
        self.init(string: string, attributes: style.textAttributes)
    }
    
    static func styled(markdown: String, styler: Styler = NSAttributedString.defaultStyler) -> NSAttributedString? {
        let d = Down(markdownString: markdown)

        do {
            return try d.toAttributedString(styler: styler)
        } catch {
            print(error)
        }

        return nil
    }
    
    static let defaultStyler = TextileStyler(
        h1: .header.sansSerif.h1,
        h2: .header.sansSerif.h2,
        h3: .header.sansSerif.h3,
        h4: .header.sansSerif.h4,
        h5: .header.sansSerif.h5,
        h6: .header.sansSerif.h6,
        body: .body.sansSerif,
        monospace: .body.monospace
    )
}

public extension NSMutableAttributedString {
    func updateStyle(_ withStyle: (Style?) -> (Style)) {
        let range = NSRange(location: 0, length: length)
        enumerateAttribute(.style, in: range, options: []) { existingStyle, range, _ in
            let baseStyle = existingStyle as? Style
            addAttributes(withStyle(baseStyle).textAttributes, range: range)
        }
    }
}

extension NSAttributedString.Key {
    static let style: Self = NSAttributedString.Key(rawValue: "textile.style")
}
