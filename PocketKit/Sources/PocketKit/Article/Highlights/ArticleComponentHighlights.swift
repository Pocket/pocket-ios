// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import DiffMatchPatch
import SharedPocketKit
import Sync
import UIKit

extension Array where Element == ArticleComponent {
    /// Apply an array of patches to an array of `ArticleComponent`
    /// - Parameter patches: the patches to apply
    /// - Returns: the patched components
    func highlighted(_ patches: [String]) -> [ArticleComponent] {
        let text = rawText
        guard !text.isEmpty else {
            return self
        }
        let diffMatchPatch = DiffMatchPatch()
        diffMatchPatch.match_Distance = HighlightConstants.diffMatchPatchDistance
        diffMatchPatch.match_Threshold = HighlightConstants.diffMatchPatchThreshold
        let totalPatches = patches.reduce(into: [Patch]()) {
            if let patches = try? diffMatchPatch.patch_(fromText: $1) as? [Patch] {
                $0.append(contentsOf: patches)
            }
        }
        guard let patchedResult = diffMatchPatch.patch_apply(totalPatches, to: text)?.first as? String else {
            Log.capture(message: "Unable to patch article")
            return self
        }
        do {
            let normalizedComponents = try normalizedComponents(patchedResult)
            return mergedComponents(normalizedComponents) ?? self
        } catch {
            Log.capture(error: error)
            return self
        }
    }

    private var highlightableComponents: [Highlightable] {
        return self.compactMap { component in
            if case let .text(textComponent) = component {
                return textComponent
            }
            if case let .blockquote(blockquoteComponent) = component {
                return blockquoteComponent
            }
            if case let .bulletedList(bulletedListComponent) = component {
                return bulletedListComponent
            }
            if case let .codeBlock(codeBlockComponent) = component {
                return codeBlockComponent
            }
            if case let .heading(headingComponent) = component {
                return headingComponent
            }
            if case let .numberedList(numberedListComponent) = component {
                return numberedListComponent
            }
            return nil
        }
    }

    private var rawText: String {
        var blob = String()

        highlightableComponents.enumerated().forEach {
            blob.append($0.element.content)
            if $0.offset < highlightableComponents.count - 1 {
                blob.append(HighlightConstants.componentSeparator)
            }
        }
        return blob
    }

    private func mergedComponents(_ patchedComponents: [String]) -> [ArticleComponent]? {
        guard
                self.count >= patchedComponents.count,
                !patchedComponents.isEmpty else {
            return nil
        }
        var mergedComponents = [ArticleComponent]()
        var patchedIndex = 0

        forEach {
            if let content = patchedComponents[safe: patchedIndex] {
                switch $0 {
                case .text:
                    mergedComponents.append(.text(TextComponent(content: content)))
                    patchedIndex += 1
                case .heading(let headingComponent):
                    mergedComponents.append(.heading(HeadingComponent(content: content, level: headingComponent.level)))
                    patchedIndex += 1
                case .codeBlock(let codeBlockComponent):
                    mergedComponents.append(.codeBlock(CodeBlockComponent(language: codeBlockComponent.language, text: content)))
                    patchedIndex += 1
                case .bulletedList(let bulletedListComponent):
                    let levels = bulletedListComponent.rows.map { $0.level }
                    let rows = content.components(separatedBy: "\n").enumerated().map { row in
                        BulletedListComponent.Row(content: row.element, level: UInt(levels[row.offset]))
                    }
                    mergedComponents.append(.bulletedList(BulletedListComponent(rows: rows)))
                    patchedIndex += 1
                case .numberedList(let numberedListComponent):
                    let levels = numberedListComponent.rows.map { $0.level }
                    let indexes = numberedListComponent.rows.map { $0.index }
                    let rows = content.components(separatedBy: "\n").enumerated().map { row in
                        NumberedListComponent.Row(content: row.element, level: UInt(levels[row.offset]), index: UInt(indexes[row.offset]))
                    }
                    mergedComponents.append(.numberedList(NumberedListComponent(rows: rows)))
                    patchedIndex += 1
                case .blockquote:
                    mergedComponents.append(.blockquote(BlockquoteComponent(content: content)))
                    patchedIndex += 1
                default:
                    mergedComponents.append($0)
                }
            }
        }
        return mergedComponents
    }

    private func normalizedComponents(_ patchedBlob: String) throws -> [String] {
        var patchedComponents = patchedBlob.components(separatedBy: HighlightConstants.componentSeparator)

        let scanner = Scanner(string: patchedBlob)
        var componentCursor = 0
        var tagStack = [String]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString(HighlightConstants.commonTag) != nil else {
                return patchedComponents
            }
            let beforeIndex = Swift.max(patchedBlob.index(before: scanner.currentIndex), patchedBlob.startIndex)
            let character = String(patchedBlob[beforeIndex])
            if character == HighlightConstants.startTagIdentifier {
                tagStack.append(HighlightConstants.highlightStartTag)
            }
            if character == HighlightConstants.endTagIdentifier {
                guard !tagStack.isEmpty else {
                    // in the entire blob, we are not supposed to find a closing tag without an opening tag
                    throw HighlightError.invalidPatch(componentCursor)
                }
                tagStack.removeLast()
            }
            if character == HighlightConstants.separatorIdentifier {
                if !tagStack.isEmpty {
                    var currentComponent = patchedComponents[componentCursor]
                    var nextComponent = patchedComponents[componentCursor + 1]
                    tagStack.forEach { _ in
                        currentComponent.insert(contentsOf: HighlightConstants.highlightEndTag, at: currentComponent.endIndex)
                        nextComponent.insert(contentsOf: HighlightConstants.highlightStartTag, at: nextComponent.startIndex)
                    }
                    patchedComponents[componentCursor] = currentComponent
                    patchedComponents[componentCursor + 1] = nextComponent
                }
                componentCursor += 1
            }
            if !scanner.isAtEnd {
                scanner.currentIndex = patchedBlob.index(after: scanner.currentIndex)
            }
        }
        return patchedComponents
    }
}

extension NSAttributedString {
    func highlighted() -> NSAttributedString {
        let highlightableString = self.string
        guard highlightableString.contains(HighlightConstants.commonHighlightTag) else {
            return self
        }
        let scanner = Scanner(string: highlightableString)

        var highlightableRanges = [Range<String.Index>]()
        var indexStack = [String.Index]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString(HighlightConstants.commonHighlightTag) != nil else {
                continue
            }
            let beforeIndex = max(highlightableString.index(before: scanner.currentIndex), highlightableString.startIndex)
            let character = String(highlightableString[beforeIndex])
            if character == HighlightConstants.startTagIdentifier {
                indexStack.append(scanner.currentIndex)
            }
            if character == HighlightConstants.endTagIdentifier {
                let tagIndex = highlightableString.index(before: beforeIndex)
                if let upperBound = indexStack.popLast() {
                    let range = Range<String.Index>(uncheckedBounds: (upperBound, tagIndex))
                    highlightableRanges.append(range)
                }
            }
            if !scanner.isAtEnd {
                scanner.currentIndex = highlightableString.index(after: scanner.currentIndex)
            }
        }
        let mutable = NSMutableAttributedString(attributedString: self)
        highlightableRanges.forEach {
            let nsRange = NSRange($0, in: highlightableString)
            mutable.addAttribute(.backgroundColor, value: HighlightConstants.highlightColor, range: nsRange)
            mutable.addAttribute(.foregroundColor, value: HighlightConstants.highlightedTextColor, range: nsRange)
        }
        mutable.mutableString.replaceOccurrences(
            of: HighlightConstants.highlightStartTag,
            with: "",
            range: NSRange(
                location: 0,
                length: mutable.mutableString.length
            )
        )
        mutable.mutableString.replaceOccurrences(
            of: HighlightConstants.highlightEndTag,
            with: "",
            range: NSRange(
                location: 0,
                length: mutable.mutableString.length
            )
        )
        return mutable
    }
}

private enum HighlightConstants {
    /// diff-match-patch
    static let diffMatchPatchDistance = 3000
    static let diffMatchPatchThreshold = 0.65
    /// separators
    static let componentSeparator = "<_pkt_>"
    static let listRowSeparator = "\n"
    /// tags & identifiers
    static let highlightStartTag = "<pkt_tag_annotation>"
    static let highlightEndTag = "</pkt_tag_annotation>"
    // tag to scan the string for highlights: common to start, end and component separator
    static let commonTag = "pkt_"
    // tag to scan the attributed string in order to apply highlights
    static let commonHighlightTag = "pkt_tag_annotation>"
    static let startTagIdentifier = "<"
    static let endTagIdentifier = "/"
    static let separatorIdentifier = "_"
    /// colors
    static let highlightColor = UIColor(displayP3Red: 250/255, green: 233/255, blue: 199/255, alpha: 0.8)
    static let highlightedTextColor = UIColor.black
}

enum HighlightError: Error {
    case noPatches
    case invalidPatch(Int)
}
