import UIKit


// An object that conforms to this protocol is commonly capable of responding to
// (overridden) events that occur within a PocketTextView nested within a PocketTextCell.
protocol ArticleComponentTextCellDelegate: AnyObject {
    func articleComponentTextCell(_ cell: ArticleComponentTextCell, didShareText: String?)
    func articleComponentTextCell(_ cell: ArticleComponentTextCell, shouldOpenURL url: URL) -> Bool
}

// An object that conforms to this protocol is capable of delegating actions
// commonly performed within the cell, typically interactions with a PocketTextView.
protocol ArticleComponentTextCell: ArticleComponentTextViewDelegate {
    var delegate: ArticleComponentTextCellDelegate? { get set }
}

// Apply default implementations of PocketTextViewDelegate callbacks
// so that this code can be reused across conforming cells.
extension ArticleComponentTextCell {
    func pocketTextViewDidSelectShareAction(_ textView: ArticleComponentTextView) {
        let selectedText =  (textView.text as NSString).substring(with: textView.selectedRange)
        delegate?.articleComponentTextCell(self, didShareText: selectedText)
    }
    
    func pocketTextView(_ textView: ArticleComponentTextView, shouldOpenURL url: URL) -> Bool {
        return delegate?.articleComponentTextCell(self, shouldOpenURL: url) ?? true
    }
}

// An object that conforms to this protocol is able to respond to (overridden)
// events that occur within a PocketTextView.
protocol ArticleComponentTextViewDelegate: AnyObject {
    func pocketTextViewDidSelectShareAction(_ textView: ArticleComponentTextView)
    func pocketTextView(_ textView: ArticleComponentTextView, shouldOpenURL url: URL) -> Bool
}

// A subclass of UITextView that overrides certain actions (e.g Share),
// and delegates the response to these actions to its delegate.
class ArticleComponentTextView: UITextView {
    var actionDelegate: ArticleComponentTextViewDelegate? = nil
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .clear
        textContainerInset = .zero
        self.textContainer.lineFragmentPadding = .zero
        isEditable = false
        isScrollEnabled = false
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
    
    @objc
    func _share(_ sender: Any?) {
        actionDelegate?.pocketTextViewDidSelectShareAction(self)
    }
}

extension ArticleComponentTextView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        return actionDelegate?.pocketTextView(self, shouldOpenURL: URL) ?? true
    }
}
