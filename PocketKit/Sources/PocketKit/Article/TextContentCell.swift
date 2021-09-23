// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit


protocol TextContentCellDelegate: AnyObject {
    func textContentCell(
        _ cell: TextContentCell,
        didShareSelecedText selectedText: String
    )
    
    func textContentCell(
        _ cell: TextContentCell,
        shouldOpenURL url: URL
    ) -> Bool
}

class TextContentCell: UICollectionViewCell {
    private let textView = TextViewWithCustomShareAction()

    weak var delegate: TextContentCellDelegate?

    var selectedText: String {
        (textView.text as NSString).substring(with: textView.selectedRange)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

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

    var attributedText: NSAttributedString? {
        get {
            textView.attributedText
        }
        set {
            textView.attributedText = newValue
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}

extension TextContentCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return delegate?.textContentCell(self, shouldOpenURL: URL) ?? true
    }
}

extension TextContentCell: TextViewWithCustomShareActionDelegate {
    fileprivate func textViewDidSelectShareAction(_ textView: TextViewWithCustomShareAction) {
        delegate?.textContentCell(self, didShareSelecedText: selectedText)
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
