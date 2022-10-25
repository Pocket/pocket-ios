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

  public static var __parentType: ParentType { PocketGraph.Objects.MarticleBlockquote }
  public static var __selections: [Selection] { [
    .field("content", Markdown.self),
  ] }

  /// Markdown text content.
  public var content: Markdown { __data["content"] }
}
