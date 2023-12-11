// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleHeadingParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleHeadingParts on MarticleHeading { __typename content level }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleHeading }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("content", PocketGraph.Markdown.self),
    .field("level", Int.self),
  ] }

  /// Heading text, in markdown.
  public var content: PocketGraph.Markdown { __data["content"] }
  /// Heading level. Restricted to values 1-6.
  public var level: Int { __data["level"] }

  public init(
    content: PocketGraph.Markdown,
    level: Int
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleHeading.typename,
        "content": content,
        "level": level,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleHeadingParts.self)
      ]
    ))
  }
}
