// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleTextParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleTextParts on MarticleText {
      __typename
      content
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleText }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("content", PocketGraph.Markdown.self),
  ] }

  /// Markdown text content. Typically, a paragraph.
  public var content: PocketGraph.Markdown { __data["content"] }
}
