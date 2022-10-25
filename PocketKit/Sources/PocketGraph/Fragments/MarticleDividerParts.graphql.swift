// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleDividerParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleDividerParts on MarticleDivider {
      __typename
      content
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.MarticleDivider }
  public static var __selections: [Selection] { [
    .field("content", Markdown.self),
  ] }

  /// Always '---'; provided for convenience if building a markdown string
  public var content: Markdown { __data["content"] }
}
