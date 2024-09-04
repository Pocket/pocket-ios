// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import Textile
import UIKit

// An object that conforms to this protocol is commonly capable of responding to
// (overridden) events that occur within a PocketTextView nested within a PocketTextCell.
@MainActor
protocol ArticleComponentTextCellDelegate: AnyObject {
    func articleComponentTextCell(_ cell: ArticleComponentTextCell, didShareText: String?)
    func articleComponentTextCell(_ cell: ArticleComponentTextCell, shouldOpenURL url: URL) -> Bool
    func articleComponentTextCell(_ cell: ArticleComponentTextCell, contextMenuConfigurationForURL url: URL) -> UIContextMenuConfiguration?
}

// An object that conforms to this protocol is capable of delegating actions
// commonly performed within the cell, typically interactions with a PocketTextView.
@MainActor
protocol ArticleComponentTextCell: ArticleComponentTextViewDelegate {
    var delegate: ArticleComponentTextCellDelegate? { get set }
    var componentIndex: Int { get set }
    var onHighlight: ((Int, NSRange, String, String) -> Void)? { get set }
    func highlightAll()
    var isFullyHighlighted: Bool { get }
}

// Apply default implementations of PocketTextViewDelegate callbacks
// so that this code can be reused across conforming cells.
extension ArticleComponentTextCell {
    func articleComponentTextViewDidSelectShareAction(_ textView: ArticleComponentTextView) {
        let selectedText =  (textView.text as NSString).substring(with: textView.selectedRange)
        delegate?.articleComponentTextCell(self, didShareText: selectedText)
    }

    func articleComponentTextView(_ textView: ArticleComponentTextView, shouldOpenURL url: URL) -> Bool {
        return delegate?.articleComponentTextCell(self, shouldOpenURL: url) ?? true
    }

    func articleComponentTextView(_ textView: ArticleComponentTextView, contextMenuConfigurationForURL url: URL) -> UIContextMenuConfiguration? {
        return delegate?.articleComponentTextCell(self, contextMenuConfigurationForURL: url)
    }
}

// An object that conforms to this protocol is able to respond to (overridden)
// events that occur within a PocketTextView.
@MainActor
protocol ArticleComponentTextViewDelegate: AnyObject {
    func articleComponentTextViewDidSelectShareAction(_ textView: ArticleComponentTextView)
    func articleComponentTextView(_ textView: ArticleComponentTextView, shouldOpenURL url: URL) -> Bool
    func articleComponentTextView(_ textView: ArticleComponentTextView, contextMenuConfigurationForURL url: URL) -> UIContextMenuConfiguration?
}

// A subclass of UITextView that overrides certain actions (e.g Share),
// and delegates the response to these actions to its delegate.
class ArticleComponentTextView: UITextView {
    var actionDelegate: ArticleComponentTextViewDelegate?

    var onHighlight: ((NSRange, String, String) -> Void)?

    private var urlTextRange: UITextRange?

    private var fullRange: NSRange {
        NSMutableAttributedString(attributedString: attributedText).mutableString.range(of: attributedText.string)
    }

    var isFullyHighlighted: Bool {
        attributedText.isFullyHighlighted(fullRange)
    }

    static func makeArticleComponentTextView() -> ArticleComponentTextView {
        let view = ArticleComponentTextView(usingTextLayoutManager: true)
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = .zero
        view.isEditable = false
        view.isScrollEnabled = false
        view.delegate = view

        view.linkTextAttributes = [.foregroundColor: UIColor(.ui.black1)]
        view.interactions
            .filter { $0 is UIContextMenuInteraction }
            .forEach { view.removeInteraction($0) }
        view.addInteraction(UIContextMenuInteraction(delegate: view))
        return view
    }

    private override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }

    @objc
    func _share(_ sender: Any?) {
        actionDelegate?.articleComponentTextViewDidSelectShareAction(self)
    }

    func highilghtAll() {
        applyHighlight(fullRange)
    }

    private func applyHighlight(_ range: NSRange) {
        let mutable = NSMutableAttributedString(attributedString: self.attributedText)
        mutable.addAttribute(.backgroundColor, value: UIColor(.ui.highlight), range: range)
        let quote = mutable.mutableString.substring(with: range)
        self.attributedText = mutable
        onHighlight?(range, quote, String(mutable.mutableString))
    }
}

extension ArticleComponentTextView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        return actionDelegate?.articleComponentTextView(self, shouldOpenURL: URL) ?? true
    }

    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        guard !attributedText.isHighlighted(in: range), onHighlight != nil else {
            return UIMenu(children: suggestedActions)
        }

        let highlightAction = UIAction(title: Localization.EditAction.highlight) { [weak self] action in
            self?.applyHighlight(range)
        }

        var newActions = suggestedActions

        if newActions.count > 1 {
            newActions.insert(highlightAction, at: 1)
        } else {
            newActions.append(highlightAction)
        }
        return UIMenu(children: newActions)
    }
}

extension ArticleComponentTextView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        var range = NSRange()
        let attributes = attributedText.attributes(at: index, effectiveRange: &range)
        let start = position(from: beginningOfDocument, offset: range.location)!
        let end = position(from: start, offset: range.length)!
        urlTextRange = textRange(from: start, to: end)!

        if let url = attributes[.link] as? URL {
            return actionDelegate?.articleComponentTextView(self, contextMenuConfigurationForURL: url)
        }

        return nil
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForHighlightingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let previewParameters = UIPreviewParameters()
        previewParameters.backgroundColor = .clear
        let preview = UITargetedPreview(view: self, parameters: previewParameters)
        return preview
    }

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let previewParameters = UIPreviewParameters()
        previewParameters.backgroundColor = .clear
        let preview = UITargetedPreview(view: self, parameters: previewParameters)
        return preview
    }
}

private extension NSAttributedString {
    /// Checks if an highlight already exists anywhere in the range
    /// - Parameter range: the provided range
    /// - Returns: true if highlighted text is found, false otherwise
    func isHighlighted(in range: NSRange) -> Bool {
        var isHighlighted = false
        enumerateAttribute(.backgroundColor, in: range) { value, range, _ in
            if let color = value as? UIColor, color == UIColor(.ui.highlight) {
                isHighlighted = true
            }
        }
        return isHighlighted
    }

    func isFullyHighlighted(_ fullRange: NSRange) -> Bool {
        var isFullyHighlighted = false
        enumerateAttribute(.backgroundColor, in: fullRange) { value, range, _ in
            if let color = value as? UIColor, color == UIColor(.ui.highlight), fullRange == range {
                isFullyHighlighted = true
            }
        }
        return isFullyHighlighted
    }
}
