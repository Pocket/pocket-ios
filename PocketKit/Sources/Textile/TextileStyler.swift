import UIKit
import Down


public class TextileStyler: Styler {
    private let h1: Style
    private let h2: Style
    private let h3: Style
    private let h4: Style
    private let h5: Style
    private let h6: Style
    private let body: Style
    private let monospace: Style
    
    public init(
        h1: Style,
        h2: Style,
        h3: Style,
        h4: Style,
        h5: Style,
        h6: Style,
        body: Style,
        monospace: Style,
        modifier: StylerModifier
    ) {
        self.h1 = h1.modified(by: modifier)
        self.h2 = h2.modified(by: modifier)
        self.h3 = h3.modified(by: modifier)
        self.h4 = h4.modified(by: modifier)
        self.h5 = h5.modified(by: modifier)
        self.h6 = h6.modified(by: modifier)
        self.body = body.modified(by: modifier)
        self.monospace = monospace.adjustingSize(by: modifier.fontSizeAdjustment)
    }
    
    public func style(document str: NSMutableAttributedString) {
        
    }
    
    public func style(blockQuote str: NSMutableAttributedString, nestDepth: Int) {
        
    }
    
    public func style(list str: NSMutableAttributedString, nestDepth: Int) {
        
    }
    
    public func style(listItemPrefix str: NSMutableAttributedString) {
        
    }
    
    public func style(item str: NSMutableAttributedString, prefixLength: Int) {
        
    }
    
    public func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {
        
    }
    
    public func style(htmlBlock str: NSMutableAttributedString) {
        
    }
    
    public func style(customBlock str: NSMutableAttributedString) {
        
    }
    
    public func style(paragraph str: NSMutableAttributedString) {
        
    }
    
    public func style(heading str: NSMutableAttributedString, level: Int) {
        var headingStyle: Style
        switch level {
        case 1: headingStyle = h1
        case 2: headingStyle = h2
        case 3: headingStyle = h3
        case 4: headingStyle = h4
        case 5: headingStyle = h5
        case 6: headingStyle = h6
        default: headingStyle = body
        }
        
        str.updateStyle { existingStyle in
            guard let existingStyle = existingStyle else {
                return headingStyle
            }

            headingStyle = headingStyle.with(slant: existingStyle.fontDescriptor.slant)
            
            if existingStyle.fontDescriptor.family == monospace.fontDescriptor.family {
                headingStyle = headingStyle
                    .with(family: existingStyle.fontDescriptor.family)
                    .with(backgroundColor: .ui.grey6)
            }
            
            return headingStyle
        }
    }
    
    public func style(thematicBreak str: NSMutableAttributedString) {
        
    }
    
    public func style(text str: NSMutableAttributedString) {
        str.updateStyle { _ in
            body
        }
    }
    
    public func style(softBreak str: NSMutableAttributedString) {
        
    }
    
    public func style(lineBreak str: NSMutableAttributedString) {
        
    }
    
    public func style(code str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            monospace.with(backgroundColor: .ui.grey6)
        }
    }
    
    public func style(htmlInline str: NSMutableAttributedString) {
        
    }
    
    public func style(customInline str: NSMutableAttributedString) {
        
    }
    
    public func style(emphasis str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            (existingStyle ?? body).with(slant: .italic)
        }
    }
    
    public func style(strong str: NSMutableAttributedString) {
        str.updateStyle { existingStyle in
            (existingStyle ?? body).with(weight: .bold)
        }
    }
    
    public func style(link str: NSMutableAttributedString, title: String?, url: String?) {
        str.updateStyle { existingStyle in
            (existingStyle ?? body).with(underlineStyle: .single)
        }
        
        if let urlString = url, let url = URL(string: urlString) {
            let range = NSRange(location: 0, length: str.length)
            str.addAttribute(.link, value: url, range: range)
        }
    }
    
    public func style(image str: NSMutableAttributedString, title: String?, url: String?) {
        
    }
}
