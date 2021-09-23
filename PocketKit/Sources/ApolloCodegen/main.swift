// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
