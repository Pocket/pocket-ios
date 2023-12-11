// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Danger
import DangerSwiftCoverage
import Foundation

let danger = Danger()

lint()
coverage()
xcodeEnvironmentVariables()
changedFiles()

func changedFiles() {
    message("Edited \(danger.git.modifiedFiles.count) files")
    message("Created \(danger.git.createdFiles.count) files")
}

func lint() {
    let violations = SwiftLint.lint(.all(directory: "./"), inline: true, configFile: ".swiftlint.yml", strict: true, quiet: false)
    if violations.isEmpty {
        message("No SwiftLint violations! 🎉")
    }
}

func coverage() {
    guard let xcresult = ProcessInfo.processInfo.environment["BITRISE_XCRESULT_PATH"]?.escapeString() else {
        fail("Could not get the BITRISE_XCRESULT_PATH to generage code coverage")
        return
    }

    Coverage.xcodeBuildCoverage(
        .xcresultBundle(xcresult),
        minimumCoverage: 50
    )
}

func xcodeEnvironmentVariables() {
    message("Checking XCode Environment Variables")

    let snowplowPostPath = #"""
            key = "SNOWPLOW_POST_PATH"
            value = "com.snowplowanalytics.snowplow/tp2"
            isEnabled = "YES">
"""#

    let modifiedXcodeSchemes = danger.git.modifiedFiles.filter { $0.contains(".xcscheme") }
    for scheme in modifiedXcodeSchemes where danger.utils.readFile(scheme).contains(snowplowPostPath) {
        fail("SNOWPLOW_POST_PATH must be disabled")
    }
}

extension String {
    // Helper function to escape (iOS) in our file name for xcov.
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "(", with: "\\(")
        newString = newString.replacingOccurrences(of: ")", with: "\\)")
        newString = newString.replacingOccurrences(of: " ", with: "\\ ")
        return newString
    }
}
