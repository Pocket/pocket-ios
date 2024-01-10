// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import DiffMatchPatch
import SharedPocketKit
import Sync
import UIKit

/// Component highlight, represented by its quote and range in the component
struct ArticleComponentHighlight {
    let range: Range<String.Index>
    let quote: String
}

/// Highlighted string, represented by an attributed string with highlighted text,
/// and a list of corresponding component highlights
struct HighlightedString {
    let content: NSAttributedString
    let highlights: [ArticleComponentHighlight]
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
        let sortedPatches = patches.sorted {
            guard let firstIndex = textIndex(patch: $0),
                    let secondIndex = textIndex(patch: $1) else {
                // if there's no comparison to be made, just keep the existing order
                return true
            }
            return firstIndex < secondIndex
        }
        let diffMatchPatch = DiffMatchPatch()
        diffMatchPatch.match_Distance = HighlightConstants.diffMatchPatchDistance
        diffMatchPatch.match_Threshold = HighlightConstants.diffMatchPatchThreshold
        // convert text patches into Patch objects
        let totalPatches = sortedPatches.reduce(into: [Patch]()) {
            if let patches = try? diffMatchPatch.patch_(fromText: $1) as? [Patch] {
                $0.append(contentsOf: patches)
            }
        }
        // feed the array of Patch to DiffMatchPatch
        guard let patchedResult = diffMatchPatch.patch_apply(totalPatches, to: text)?.first as? String else {
            Log.capture(message: "Unable to patch article")
            return self
        }
        do {
            let textComponents = try textComponentsWithHighlights(patchedResult)
            return mergedComponents(textComponents)
        } catch {
            Log.capture(error: error)
            return self
        }
    }

    /// Extract highlightable components from the current array (excluding images, videos, etc)
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

    /// Convert the highlightable components into a markdown blob
    /// components in the blob are separated by the separator tag
    private var rawText: String {
        highlightableComponents
            .map { $0.content }
            .joined(separator: HighlightConstants.componentSeparator)
    }

    /// Extract the first text index from a patch
    /// - Parameter patch: the patch
    /// - Returns: the text index as Integer, if it was found, or nil
    private func textIndex(patch: String) -> Int? {
        guard let regex = try? Regex(HighlightConstants.indexPattern),
                let match = patch.firstMatch(of: regex),
              // we want the match to capture the value
              match.count > 1,
              // and we want the capture to contain a valid string
              let matchedString = match[1].substring else {
            return nil
        }
        // return the integer value, if the string contains a valid number, or nil
        return Int(matchedString)
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
        var patchedComponents = text.components(separatedBy: HighlightConstants.componentSeparator)

        let scanner = Scanner(string: text)
        var componentCursor = 0
        var tagStack = [String]()

        while !scanner.isAtEnd {
            guard scanner.scanUpToString(HighlightConstants.commonTag) != nil else {
                return patchedComponents
            }
            let beforeIndex = Swift.max(text.index(before: scanner.currentIndex), text.startIndex)
            let character = String(text[beforeIndex])
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
                scanner.currentIndex = text.index(after: scanner.currentIndex)
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
            return HighlightedString(content: self, highlights: [])
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

        while !scanner.isAtEnd {
            guard scanner.scanUpToString(HighlightConstants.commonHighlightTag) != nil else {
                continue
            }
            let beforeIndex = max(highlightableString.index(before: scanner.currentIndex), highlightableString.startIndex)
            let character = String(highlightableString[beforeIndex])
            // Found the start of a highlight
            if character == HighlightConstants.startTagIdentifier {
                indexStack.append(beforeIndex)
                if let range = resultingString.firstRange(of: HighlightConstants.highlightStartTag) {
                    // remove the tag from the copy string
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
        let highlights = resultingRanges.map {
            ArticleComponentHighlight(range: $0, quote: String(resultingString[$0]))
        }
        return HighlightedString(content: mutable, highlights: highlights)
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
    /// Regex to find text indexes in patches
    static let indexPattern = "@@[ \t]-([0-9]+),"
    /// colors
    static let highlightColor = UIColor(displayP3Red: 250/255, green: 233/255, blue: 199/255, alpha: 0.8)
    static let highlightedTextColor = UIColor.black
}
