import Foundation
import Down

private extension Style {
    static let h1: Style = .header.serif.h1
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.97))
        }

    static let h2: Style = .header.serif.h2
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.99))
        }

    static let h3: Style = .header.serif.h3
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.95))
        }

    static let h4: Style = .header.serif.h4
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.96))
        }

    static let h5: Style = .header.serif.h5
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.89))
        }

    static let h6: Style = .header.serif.h6
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(0.9))
        }

    static let bodyText: Style = .body.serif
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.1))
        }

    static let monospace: Style = .body.monospace
}

public extension NSAttributedString {
    convenience init(string: String, style: Style) {
        self.init(string: string, attributes: style.textAttributes)
    }
    
    static func styled(markdown: String, styler: Styler) -> NSAttributedString? {
        let d = Down(markdownString: markdown)

        do {
            return try d.toAttributedString(styler: styler)
        } catch {
            print(error)
        }

        return nil
    }
    
    static func defaultStyler(with modifier: StylerModifier, bodyStyle: Style? = nil) -> Styler {
        TextileStyler(
            h1: .h1,
            h2: .h2,
            h3: .h3,
            h4: .h4,
            h5: .h5,
            h6: .h6,
            body: bodyStyle ?? .bodyText,
            monospace: .monospace,
            modifier: modifier
        )
    }
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
