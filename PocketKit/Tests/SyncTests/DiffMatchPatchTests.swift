import DiffMatchPatch
import XCTest

// I've just been using this as a rough scratch pad to experiment with DiffMatchPatch
// Eventually this should go away and be replaced by a test that actually tests something
class DiffMatchPatchTests: XCTestCase {
    let textComponents = [
        "Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. ",
        "Etiam porta sem malesuada magna mollis euismod. ",
        "Maecenas faucibus mollis interdum. ",
        "Vestibulum id ligula porta felis euismod semper. ",
        "Praesent commodo cursus magna, vel scelerisque nisl consectetur et.",
    ]

    lazy var allText: String = {
        textComponents.joined(separator: "")
    }()

    func test_whenHighlightIsInSingleComponent_findsCorrectIndexes() throws {
        let patchText = getPatchText(forText: allText, highlightedText: "faucibus mollis")
        let delimiterStart = "#"
        let delimiterEnd = "%"

        let diffMatchPatch = DiffMatchPatch()
        diffMatchPatch.match_Threshold = 0.04


        let patches = try diffMatchPatch.patch_(fromText: patchText)
        let near = patchStart1(patches: patches, patchIndex: 0)


        let something = diffMatchPatch.match_main(forText: allText, pattern: "faucibus mollis", near: near)
        print(something)
//
//        let patches = try diffMatchPatch.patch_(fromText: patchText)
//        adjustPatchText(patches: patches, index: 0, newText: delimiterStart)
//        adjustPatchText(patches: patches, index: 1, newText: delimiterEnd)
//
//        var totalLength = 0
//        let origStart = patchStart1(patches: patches, patchIndex: 0)
//        let updatedComponents = textComponents.enumerated().map { index, component in
//            print("Applying patch to: \(component)")
//            print("Patch start: \(patchStart1(patches: patches, patchIndex: 0))")
//
//            adjustPatchStart1(
//                patches: patches,
//                patchIndex: 0,
//                start1: Int(origStart) - max(totalLength, 0) + patchDiffOffset(patches: patches, patchIndex: 0)
//            )
//
//
////            adjustPatchStart1(patches: patches, patchIndex: 0, start1Delta: 4)
//            print("Adjusted Patch start: \(patchStart1(patches: patches, patchIndex: 0))")
//
//            let patchResult = diffMatchPatch.patch_apply([patches[0]] as? [Any], to: component)
//            totalLength += component.count
//            if !patchSucceeded(result: patchResult, at: 0) {
////                print("Adjusting beginning patch start by \(component.count)")
////                adjustPatchStart1(patches: patches, patchIndex: 0, start1Delta: -component.count)
//            }
//
////            if !patchSucceeded(result: patchResult, at: 1) {
//////                print("Adjusting end patch start by \(component.count)")
////                adjustPatchStart1(patches: patches, patchIndex: 1, start1Delta: -component.count)
////            }
//
//            if patchSucceeded(result: patchResult, at: 0) { //}|| patchSucceeded(result: patchResult, at: 1) {
////                print("Patch succeeded: \(patchedString(result: patchResult))")
//                return patchedString(result: patchResult) ?? component
//            } else {
////                print("Patch failed")
//            }
//
//            return component
//        }

//        XCTAssertEqual(updatedComponents, [
//            "Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. ",
//            "Etiam porta sem malesuada magna mollis euismod. ",
//            "Maecenas \(delimiterStart)faucibus mollis\(delimiterEnd) interdum. ",
//            "Vestibulum id ligula porta felis euismod semper. ",
//            "Praesent commodo cursus magna, vel scelerisque nisl consectetur et."
//        ])
    }

    func getPatchText(forText text: String, highlightedText: String) -> String {
        let textWithHighlights = text.replacingOccurrences(of: highlightedText, with: "<pkt_tag_annotation>\(highlightedText)</pkt_tag_annotation>")

        let diffMatchPatch = DiffMatchPatch()
        let diffs = diffMatchPatch.diff_main(ofOldString: text, andNewString: textWithHighlights)
        let patches = diffMatchPatch.patch_make(fromDiffs: diffs)
        let patchString = diffMatchPatch.patch_(toText: patches)

        return patchString!
    }

    func patchedString(result: [Any]?) -> String? {
        guard let result, result.count > 0 else { return nil }
        return result[0] as? String
    }

    func patchSucceeded(result: [Any]?, at index: Int) -> Bool {
        guard let result, result.count > 1,
              let patchResArr = result[1] as? [Any],
              let patchRes = patchResArr[index] as? Int else {
            return false
        }

        return patchRes == 1
    }

    func adjustPatchText(patches: NSMutableArray, index: Int, newText: String) {
        guard patches.count > index,
              let patch = patches[index] as? Patch,
              let diff = patch.diffs[1] as? Diff else {
            return
        }

        diff.text = newText
    }

    func adjustPatchStart1(patches: NSMutableArray, patchIndex: Int, start1: Int) {
        guard patches.count > patchIndex,
              let patch = patches[patchIndex] as? Patch else {
            return
        }

        patch.start1 = UInt(max(0, start1))
    }

    func patchStart1(patches: NSMutableArray, patchIndex: Int) -> UInt {
        guard patches.count > patchIndex,
              let patch = patches[patchIndex] as? Patch else {
            return 0
        }

        return patch.start1
    }

    func patchDiffOffset(patches: NSMutableArray, patchIndex: Int) -> Int {
        guard patches.count > patchIndex,
              let patch = patches[patchIndex] as? Patch,
              patch.diffs.count > 0,
              let diff = patch.diffs[0] as? Diff else {
            return 0
        }

        return diff.text.count
    }
}
