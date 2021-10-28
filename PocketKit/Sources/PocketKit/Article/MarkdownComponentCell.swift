import UIKit
import Sync


protocol MarkdownComponentCellDelegate: AnyObject {
    func markdownComponentCell(
        _ cell: MarkdownComponentCell,
        didShareSelecedText selectedText: String
    )
    
    func markdownComponentCell(
        _ cell: MarkdownComponentCell,
        shouldOpenURL url: URL
    ) -> Bool
}

class MarkdownComponentCell: UICollectionViewCell {
    private let textView = TextViewWithCustomShareAction()

    weak var delegate: MarkdownComponentCellDelegate?

    var selectedText: String {
        (textView.text as NSString).substring(with: textView.selectedRange)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.shareDelegate = self

        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    var attributedContent: NSAttributedString? {
        set {
            textView.attributedText = newValue
        }
        get {
            textView.attributedText
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}

extension MarkdownComponentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.markdownComponentCell(self, shouldOpenURL: URL) ?? true
    }
}

extension MarkdownComponentCell: TextViewWithCustomShareActionDelegate {
    fileprivate func textViewDidSelectShareAction(_ textView: TextViewWithCustomShareAction) {
        delegate?.markdownComponentCell(self, didShareSelecedText: selectedText)
    }
}

private protocol TextViewWithCustomShareActionDelegate: AnyObject {
    func textViewDidSelectShareAction(_ textView: TextViewWithCustomShareAction)
}

///
/// A text view that notifies a delegate when user shares selected text
///
private class TextViewWithCustomShareAction: UITextView {
    weak var shareDelegate: TextViewWithCustomShareActionDelegate?

    // This method is called by the system when a user taps "Share"
    // in the menu that appears when selecting text
    // It is, admittedly, a bit hackish to override this method,
    // but because of the way the responder chain works this is the simplest way to
    // handle this notification and also get access to the selected text
    @objc
    func _share(_ sender: Any?) {
        shareDelegate?.textViewDidSelectShareAction(self)
    }
}
