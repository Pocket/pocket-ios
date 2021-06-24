import ArgumentParser

struct ApolloCodegen: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "apollo-codegen",
        abstract: """
        A swift-based utility for performing Apollo-related tasks.
        """,
        subcommands: [GenerateCode.self, DownloadSchema.self]
    )
}

ApolloCodegen.main()
