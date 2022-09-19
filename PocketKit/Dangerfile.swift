import Danger
import DangerSwiftCoverage
import Foundation

let danger = Danger()
let editedFiles = danger.git.modifiedFiles + danger.git.createdFiles

// Instead of making a markdown table in the main message
// sprinkle those comments inline, this can be a bit noisy
// but it definitely feels magical.
SwiftLint.lint(.modifiedAndCreatedFiles(directory: "../"), inline: false, configFile: "../.swiftlint.yml")

let xcresult = ProcessInfo.processInfo.environment["BITRISE_XCRESULT_PATH"]!.escapeString()

Coverage.xcodeBuildCoverage(.xcresultBundle(xcresult), 
                            minimumCoverage: 50)

extension String {
    // Helper function to escape (iOS) in our file name for xcov.
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "(", with: "\\(")
        newString = newString.replacingOccurrences(of: ")", with: "\\)")
        newString = newString.replacingOccurrences(of: " ", with: "\\ ")
        return newString
    }
}