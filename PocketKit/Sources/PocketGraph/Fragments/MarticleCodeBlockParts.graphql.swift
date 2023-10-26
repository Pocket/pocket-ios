// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleCodeBlockParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment MarticleCodeBlockParts on MarticleCodeBlock { __typename text language }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.MarticleCodeBlock }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("text", String.self),
    .field("language", Int?.self),
  ] }

  /// Content of a pre tag
  public var text: String { __data["text"] }
  /// Assuming the codeblock was a programming language, this field is used to identify it.
  public var language: Int? { __data["language"] }

  public init(
    text: String,
    language: Int? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.MarticleCodeBlock.typename,
        "text": text,
        "language": language,
      ],
      fulfilledFragments: [
        ObjectIdentifier(MarticleCodeBlockParts.self)
      ]
    ))
  }
}
