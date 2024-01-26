// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import DiffMatchPatch
import SharedPocketKit
import Sync
import UIKit

struct HighlightedQuote: Identifiable {
    var id = UUID()
    let remoteID: String?
    let index: Int
    let indexPath: IndexPath
    let quote: String
}

/// Highlighted string, represented by an attributed string with highlighted text,
/// and a list of corresponding component highlights
struct HighlightedString {
    let content: NSAttributedString
    let highlightInexes: [Int]?
}

extension Array where Element == ArticleComponent {
    /// Apply an array of patches to an array of `ArticleComponent`, using `DiffMatchPatch`
    /// - Parameter patches: the patches to apply
    /// - Returns: the patched components, or self, in case of errors
    func highlighted(_ patches: [String]) -> [ArticleComponent] {
        let text = rawText
        guard !text.isEmpty else {
            return self
        }

        let indexedPatches = patches.enumerated().map { patch in
            let newElement = patch.element.replacingOccurrences(of: "%3Cpkt_tag_annotation%3E", with: "%3Cpkt_tag_annotation_\(patch.offset)%3E")
            return newElement
        }

        let diffMatchPatch = DiffMatchPatch()
        diffMatchPatch.match_Distance = HighlightConstants.diffMatchPatchDistance
        diffMatchPatch.match_Threshold = HighlightConstants.diffMatchPatchThreshold
        // convert text patches into Patch objects
        let totalPatches = indexedPatches.reduce(into: [Patch]()) {
            if let patches = try? diffMatchPatch.patch_(fromText: $1) as? [Patch] {
                $0.append(contentsOf: patches)
            }
        }
        // feed the array of Patch to DiffMatchPatch
        let patchedOutput = diffMatchPatch.patch_apply(totalPatches, to: text)
        guard let patchedText = patchedOutput?.first as? String else {
            Log.capture(message: "Unable to patch article")
            return self
        }
        do {
            let textComponents = try textComponentsWithHighlights(patchedText)
            return mergedComponents(textComponents)
        } catch {
            Log.capture(error: error)
            return self
        }
    }

    /// Extract highlightable components from the current array (excluding images, videos, etc)
    private var highlightableComponents: [Highlightable] {
        // TODO: add support for image caption highlights?
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
            if case let .image(imageComponent) = component {
                return imageComponent
            }
            return nil
        }
    }

    /// Convert the highlightable components into a markdown blob
    /// components in the blob are separated by the separator tag
    private var rawText: String {
        highlightableComponents
            .map { $0.content }
            .joined(separator: HighlightConstants.componentSeparator)
    }

    /// Merge text components back into the current array of `ArticleComponent`
    /// - Parameter patchedComponents: array of text components
    /// - Returns: the array resulting from the merge
    private func mergedComponents(_ textComponents: [String]) -> [ArticleComponent] {
        guard self.count >= textComponents.count,
              !textComponents.isEmpty else {
            return self
        }
        var mergedComponents = [ArticleComponent]()
        var patchedIndex = 0
        // cycle over the current array and, if a corresponding patched component is found, replace it
        forEach {
            if let content = textComponents[safe: patchedIndex] {
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
                    let rows = content.components(separatedBy: HighlightConstants.listRowSeparator).enumerated().map { row in
                        BulletedListComponent.Row(content: row.element, level: UInt(levels[Swift.min(row.offset, levels.count - 1)]))
                    }
                    mergedComponents.append(.bulletedList(BulletedListComponent(rows: rows)))
                    patchedIndex += 1
                case .numberedList(let numberedListComponent):
                    let levels = numberedListComponent.rows.map { $0.level }
                    let indexes = numberedListComponent.rows.map { $0.index }
                    let rows = content.components(separatedBy: HighlightConstants.listRowSeparator).enumerated().map { row in
                        NumberedListComponent.Row(content: row.element, level: UInt(levels[row.offset]), index: UInt(indexes[row.offset]))
                    }
                    mergedComponents.append(.numberedList(NumberedListComponent(rows: rows)))
                    patchedIndex += 1
                case .blockquote:
                    mergedComponents.append(.blockquote(BlockquoteComponent(content: content)))
                    patchedIndex += 1
                case .image(let imageComponent):
                    var caption: String?
                    var credit: String?
                    if let originalCaption = imageComponent.caption, !originalCaption.isEmpty, let originalCredit = imageComponent.credit, !originalCredit.isEmpty, content.contains(HighlightConstants.captionCreditSeparator) {
                        let captionComponents = content.components(separatedBy: HighlightConstants.captionCreditSeparator)
                        if captionComponents.count == 2 {
                            caption = captionComponents[0]
                            credit = captionComponents[1]
                        }
                    } else if let originalCaption = imageComponent.caption, imageComponent.credit == nil || imageComponent.credit?.isEmpty == true {
                        caption = originalCaption.isEmpty ? originalCaption : content
                    } else if imageComponent.caption == nil || imageComponent.caption?.isEmpty == true, let originalCredit = imageComponent.credit {
                        credit = originalCredit.isEmpty ? originalCredit : content
                    }
                    mergedComponents.append(
                        .image(
                            ImageComponent(
                                caption: caption,
                                credit: credit,
                                height: imageComponent.height,
                                width: imageComponent.width,
                                id: imageComponent.id,
                                source: imageComponent.source
                            )
                        )
                    )
                    patchedIndex += 1
                default:
                    mergedComponents.append($0)
                }
            }
        }
        return mergedComponents
    }

    /// Extract text components, identified by the separator tag, from a blob.
    /// Highlights are delimited by the corresponding start and end tag.
    /// If an highlight spans more than one component, it gets broken up
    /// into multiple highlights, one per component.
    /// - Parameter text: the text blob that contains separator tags and highlights.
    /// - Returns: The array of text components with highlights.
    private func textComponentsWithHighlights(_ text: String) throws -> [String] {
        let parseableText = text.replacingOccurrences(of: HighlightConstants.componentSeparator, with: HighlightConstants.parserSeparator)
        var patchedComponents = parseableText.components(separatedBy: HighlightConstants.parserSeparator)

        let scanner = Scanner(string: parseableText)
        var componentCursor = 0
        var tagStack = [String]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString(HighlightConstants.commonTag) != nil else {
                return patchedComponents
            }
            let beforeIndex = Swift.max(parseableText.index(before: scanner.currentIndex), parseableText.startIndex)
            let character = String(parseableText[beforeIndex])
            if character == HighlightConstants.startTagIdentifier {
                tagStack.append(HighlightConstants.highlightStartTag)
            }
            if character == HighlightConstants.endTagIdentifier {
                guard !tagStack.isEmpty else {
                    // in the entire blob, we are not supposed to find a closing tag without an opening tag
                    // if we do, it's probably an error from the Diff Match Patch: continue but log the error
                    Log.capture(message: "Error parsing highlights at index \(componentCursor)")
                    continue
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
                scanner.currentIndex = parseableText.index(after: scanner.currentIndex)
            }
        }
        return patchedComponents
    }
}

extension NSAttributedString {
    /// Apply highlights to an attributed string.
    /// If an attributed string contains highlight tags, those are removed
    /// and a highlight background color and text are applied to the
    /// corresponding range.
    /// - Returns: The highlighted attributed string.
    func highlighted() -> HighlightedString {
        let highlightableString = self.string
        guard highlightableString.contains(HighlightConstants.commonHighlightTag) else {
            return HighlightedString(content: self, highlightInexes: nil)
        }
        // a copy of the original string, that will reflect the visible text
        // we will remove tags in place and store highlight ranges on this one
        // it will be used to edit existing highlights directly on the component string
        var resultingString = highlightableString
        let scanner = Scanner(string: highlightableString)
        // Ranges that will be used to apply the highlights to the attributed string
        var highlightableRanges = [Range<String.Index>]()
        // Equivalent ranges on the string without the highlight tags. Used to keep track of highlighted ranges in the reader
        var resultingRanges = [Range<String.Index>]()
        // Stack that stores indexes representing the lower bound of an highlightable range
        var indexStack = [String.Index]()
        // Same as above, on the copy
        var resultingIndexStack = [String.Index]()

        var highlightIndexes = [Int]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString(HighlightConstants.commonHighlightTag) != nil else {
                continue
            }
            let beforeIndex = max(highlightableString.index(before: scanner.currentIndex), highlightableString.startIndex)
            let character = String(highlightableString[beforeIndex])
            // Found the start of a highlight
            if character == HighlightConstants.startTagIdentifier {
                indexStack.append(beforeIndex)
                // first subcase: found the start of an highlight with an index
                if let regex = try? Regex(HighlightConstants.highlightIndexPattern),
                   let match = resultingString.firstMatch(of: regex),
                   // we want the match to capture the value
                   match.count > 1,
                   // and we want the capture to contain a valid string
                   let matchedString = match[1].substring,
                   let range = resultingString.firstRange(of: HighlightConstants.indexedTag(String(matchedString))),
                   let index = Int(matchedString) {
                    highlightIndexes.append(index)
                    resultingString.removeSubrange(range)
                    resultingIndexStack.append(range.lowerBound)
                    // second subcase: found continuation of existing highlight that spans more than one component
                } else if let range = resultingString.firstRange(of: HighlightConstants.highlightStartTag) {
                    resultingString.removeSubrange(range)
                    resultingIndexStack.append(range.lowerBound)
                }
            }
            // Found the end of a highlight
            if character == HighlightConstants.endTagIdentifier {
                let tagIndex = highlightableString.index(before: beforeIndex)
                if let lowerBound = indexStack.popLast(),
                   // if the stack is not empty, it means we have overlapping highlights
                   // which we will merge onto a single one
                   indexStack.isEmpty {
                    let range = Range<String.Index>(uncheckedBounds: (lowerBound, tagIndex))
                    highlightableRanges.append(range)
                }
                if let range = resultingString.firstRange(of: HighlightConstants.highlightEndTag) {
                    // remove the tag from the copy string
                    resultingString.removeSubrange(range)
                    if let resultingLowerBound = resultingIndexStack.popLast(),
                       // same logic of overlapping highlights applies here
                       resultingIndexStack.isEmpty {
                        resultingRanges.append(Range<String.Index>(uncheckedBounds: (resultingLowerBound, range.lowerBound)))
                    }
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

        let tagsToRemove =
        highlightIndexes.map { HighlightConstants.indexedTag("\($0)") } +
        [HighlightConstants.highlightStartTag] +
        [HighlightConstants.highlightEndTag]

        tagsToRemove.forEach {
            mutable.mutableString.replaceOccurrences(
                of: $0,
                with: "",
                range: NSRange(
                    location: 0,
                    length: mutable.mutableString.length
                )
            )
        }
        return HighlightedString(content: mutable, highlightInexes: highlightIndexes)
    }
}

private enum HighlightConstants {
    /// diff-match-patch
    static let diffMatchPatchDistance = 3000
    static let diffMatchPatchThreshold = 0.65
    /// separators
    static let componentSeparator = "[||]"
    static let parserSeparator = "<_pkt_>"
    static let listRowSeparator = "\n"
    static let captionCreditSeparator = "[-]"
    /// tags & identifiers
    static let highlightStartTag = "<pkt_tag_annotation>"
    static let highlightEndTag = "</pkt_tag_annotation>"
    // tag to scan the string for highlights: common to start, end and component separator
    static let commonTag = "pkt_"
    // tag to scan the attributed string in order to apply highlights
    static let commonHighlightTag = "pkt_tag_annotation"
    static let startTagIdentifier = "<"
    static let endTagIdentifier = "/"
    static let separatorIdentifier = "_"
    // Regex to find highlight indexes in tags
    static let highlightIndexPattern = "_([0-9]+)>"
    // Indexed tag builder
    static func indexedTag(_ index: String) -> String {
        "<pkt_tag_annotation_\(index)>"
    }
    /// colors
    static let highlightColor = UIColor(displayP3Red: 250/255, green: 233/255, blue: 199/255, alpha: 0.8)
    static let highlightedTextColor = UIColor.black
}
