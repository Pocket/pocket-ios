// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleBlockquoteParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleBlockquoteParts on MarticleBlockquote { __typename content }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleBlockquote }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("content", PocketGraph.Markdown.self),
  ] }

  /// Markdown text content.
  public var content: PocketGraph.Markdown { __data["content"] }

  public init(
    content: PocketGraph.Markdown
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleBlockquote.typename,
        "content": content,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleBlockquoteParts.self)
      ]
    ))
  }
}
