import Foundation

struct FileStructure {
    private static let urlToThisFile = URL(fileURLWithPath: #filePath)

    static let root = URL(fileURLWithPath: ".", isDirectory: true, relativeTo: urlToThisFile).absoluteURL

    static let syncRoot = URL(fileURLWithPath: "../Sync", isDirectory: true, relativeTo: root).absoluteURL

    static let operationsDir = syncRoot

    static let schemaURL = URL(fileURLWithPath: "schema.json", relativeTo: syncRoot).absoluteURL

    static let schemaDir = schemaURL.deletingLastPathComponent()

    static let outputFile = URL(string: "API.swift", relativeTo: syncRoot)!

    static let tmpDir = URL(fileURLWithPath: ".tmp", isDirectory: true, relativeTo: root)
}
