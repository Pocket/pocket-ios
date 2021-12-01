import UIKit


// An object that conforms to this protocol is commonly capable of responding to
// (overridden) events that occur within a PocketTextView nested within a PocketTextCell.
protocol PocketTextCellDelegate: AnyObject {
    func pocketTextCell(_ cell: PocketTextCell, didShareText: String?)
    func pocketTextTell(_ cell: PocketTextCell, shouldOpenURL url: URL) -> Bool
}

// An object that conforms to this protocol is capable of delegating actions
// commonly performed within the cell, typically interactions with a PocketTextView.
protocol PocketTextCell: PocketTextViewDelegate {
    var delegate: PocketTextCellDelegate? { get }
}

// Apply default implementations of PocketTextViewDelegate callbacks
// so that this code can be reused across conforming cells.
extension PocketTextCell {
    func pocketTextViewDidSelectShareAction(_ textView: PocketTextView) {
        let selectedText =  (textView.text as NSString).substring(with: textView.selectedRange)
        delegate?.pocketTextCell(self, didShareText: selectedText)
    }
    
    func pocketTextView(_ textView: PocketTextView, shouldOpenURL url: URL) -> Bool {
        return delegate?.pocketTextTell(self, shouldOpenURL: url) ?? true
    }
}

// An object that conforms to this protocol is able to respond to (overridden)
// events that occur within a PocketTextView.
protocol PocketTextViewDelegate: AnyObject {
    func pocketTextViewDidSelectShareAction(_ textView: PocketTextView)
    func pocketTextView(_ textView: PocketTextView, shouldOpenURL url: URL) -> Bool
}

// A subclass of UITextView that overrides certain actions (e.g Share),
// and delegates the response to these actions to its delegate.
class PocketTextView: UITextView {
    var pocketDelegate: PocketTextViewDelegate? = nil
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
    
    @objc
    func _share(_ sender: Any?) {
        pocketDelegate?.pocketTextViewDidSelectShareAction(self)
    }
}

extension PocketTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return pocketDelegate?.pocketTextView(self, shouldOpenURL: URL) ?? true
    }
}
