import Foundation
import ApolloCodegenLib
import ArgumentParser

struct GenerateCode: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generates swift code from schema file and operations."
    )

    func run() throws {
        let options = ApolloCodegenOptions(
            codegenEngine: .typescript,
            includes: "**/*.graphql",
            mergeInFieldsFromFragmentSpreads: true,
            modifier: .public,
            namespace: nil,
            omitDeprecatedEnumCases: false,
            only: nil,
            operationIDsURL: nil,
            outputFormat: .singleFile(atFileURL: FileStructure.outputFile),
            customScalarFormat: .none,
            suppressSwiftMultilineStringLiterals: false,
            urlToSchemaFile: FileStructure.schemaURL,
            downloadTimeout: 30
        )

        try FileManager.default.createDirectory(
            at: FileStructure.tmpDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        try ApolloCodegenLib.ApolloCodegen.run(
            from: FileStructure.operationsDir,
            with: FileStructure.tmpDir,
            options: options
        )
    }
}
