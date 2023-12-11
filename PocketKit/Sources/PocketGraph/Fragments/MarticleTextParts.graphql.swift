// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleTextParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleTextParts on MarticleText { __typename content }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleText }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("content", PocketGraph.Markdown.self),
  ] }

  /// Markdown text content. Typically, a paragraph.
  public var content: PocketGraph.Markdown { __data["content"] }

  public init(
    content: PocketGraph.Markdown
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleText.typename,
        "content": content,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleTextParts.self)
      ]
    ))
  }
}
