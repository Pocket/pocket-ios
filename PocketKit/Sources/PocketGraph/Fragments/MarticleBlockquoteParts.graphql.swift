// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleBlockquoteParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleBlockquoteParts on MarticleBlockquote {
      __typename
      content
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBlockquote }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("content", PocketGraph.Markdown.self),
  ] }

  /// Markdown text content.
  public var content: PocketGraph.Markdown { __data["content"] }
}
