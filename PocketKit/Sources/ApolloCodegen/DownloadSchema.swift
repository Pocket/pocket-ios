import Foundation
import ArgumentParser
import ApolloCodegenLib


struct DownloadSchema: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "download-schema",
        abstract: "Downloads the graphql schema"
    )

    mutating func run() throws {
        let endpoint = URL(string: "https://client-api.getpocket.com/")!
        let schemaDownloadOptions = ApolloSchemaOptions(
            downloadMethod: .introspection(endpointURL: endpoint),
            outputFolderURL: FileStructure.schemaDir
        )

        try ApolloSchemaDownloader.run(
            with: FileStructure.tmpDir,
            options: schemaDownloadOptions
        )
    }
}
