// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleDividerParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleDividerParts on MarticleDivider { __typename content }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleDivider }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("content", PocketGraph.Markdown.self),
  ] }

  /// Always '---'; provided for convenience if building a markdown string
  public var content: PocketGraph.Markdown { __data["content"] }

  public init(
    content: PocketGraph.Markdown
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleDivider.typename,
        "content": content,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleDividerParts.self)
      ]
    ))
  }
}
