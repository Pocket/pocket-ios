import Foundation
import ArgumentParser
import ApolloCodegenLib


struct DownloadSchema: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "download-schema",
        abstract: "Downloads the graphql schema"
    )

    mutating func run() throws {
        try ApolloSchemaDownloader.fetch(
            with: ApolloSchemaDownloadConfiguration(
                using: .introspection(endpointURL: URL(string: "https://client-api.getpocket.com/")!),
                outputFolderURL: FileStructure.schemaDir
            )
        )
    }
}
