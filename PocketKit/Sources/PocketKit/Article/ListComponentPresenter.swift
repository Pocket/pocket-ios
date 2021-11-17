import Sync
import UIKit
import Textile


protocol ListComponent {
    var elements: [ListComponentElement] { get }
}

protocol ListComponentElement {
    var content: Markdown { get }
    var level: UInt { get }
    var prefix: String { get }
    func prefixStyle(applying settings: ReaderSettings) -> Style
}

struct ListComponentPresenter {
    private let component: ListComponent
    private let readerSettings: ReaderSettings
    
    var attributedContent: NSAttributedString? {
        let attributedContent = NSMutableAttributedString()
        for (index, element) in component.elements.enumerated() {
            // Clamp a list element's depth to 0...3 (i.e max-depth of 4) as to allow for
            // enough room for rendering content in a readable fashion, and add the appropriate indents.
            let depth = CGFloat(min(element.level, 3))

            let prefix = NSAttributedString(string: element.prefix, style: element.prefixStyle(applying: readerSettings))
            
            guard let markdown = NSAttributedString.styled(
                markdown: element.content,
                styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
            ) else {
                return nil
            }
            
            let content = NSMutableAttributedString(attributedString: prefix)
            content.append(markdown)
            
            let style = NSMutableParagraphStyle()
            style.firstLineHeadIndent = depth * 16
            style.headIndent = depth * 16 + Self.size(of: prefix).width
            
            content.addAttribute(
                .paragraphStyle,
                value: style,
                range: NSRange(location: 0, length: content.length)
            )

            if index > 0 {
                attributedContent.append(NSAttributedString("\n"))
            }
            attributedContent.append(content)
        }
        return attributedContent
    }
    
    init(component: ListComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
    }
}

private extension ListComponentPresenter {
    static func size(of attributedString: NSAttributedString, availableWidth: CGFloat = .infinity, availableHeight: CGFloat = .infinity) -> CGSize {
        guard !attributedString.string.isEmpty else {
            return .zero
        }

        let rect = attributedString.boundingRect(
            with: CGSize(width: availableWidth, height: availableHeight),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        )

        return CGSize(width: min(rect.width.rounded(.up), availableWidth), height: min(rect.height.rounded(.up), availableHeight))
    }
}

// MARK: - BulletedListComponent

extension BulletedListComponent.Row: ListComponentElement {
    var prefix: String {
        switch level {
        case 0:
            return "• "
        case 1:
            return "◦ "
        default:
            return "▪\u{fe0e} "
        }
    }
    
    func prefixStyle(applying settings: ReaderSettings) -> Style {
        .body.monospace.adjustingSize(by: settings.fontSizeAdjustment)
    }
}

extension BulletedListComponent: ListComponent {
    var elements: [ListComponentElement] {
        rows
    }
}

// MARK: - NumberedListComponent

extension NumberedListComponent.Row: ListComponentElement {
    var prefix: String {
        "\(index + 1). "
    }
    
    func prefixStyle(applying settings: ReaderSettings) -> Style {
        .body.sansSerif.modified(by: settings)
    }
}

extension NumberedListComponent: ListComponent {
    var elements: [ListComponentElement] {
        rows
    }
}
