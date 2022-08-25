//
//  ApolloGenPlugin.swift
//  
//
//  Created by Daniel Brooks on 8/24/22.
//

import PackagePlugin
import Foundation

@main
struct ApolloGenPlugin: BuildToolPlugin {
   
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
       return [
            .buildCommand(
                displayName: "Download GraphQL Schema",
                executable: try context.tool(named:"ApolloCodegen").path,
                arguments: [
                    "download-schema"
                ],
                environment: [:],
                inputFiles: [],
                outputFiles: []
            ),
            .buildCommand(
                displayName: "Generate GraphQL Schema",
                executable: try context.tool(named:"ApolloCodegen").path,
                arguments: [
                    "generate"
                ],
                environment: [:],
                inputFiles: [],
                outputFiles: []
            )
       ]
    }
}
