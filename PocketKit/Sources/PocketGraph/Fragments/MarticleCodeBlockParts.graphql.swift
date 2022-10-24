// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct MarticleCodeBlockParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment MarticleCodeBlockParts on MarticleCodeBlock {
      __typename
      text
      language
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.MarticleCodeBlock }
  public static var __selections: [Selection] { [
    .field("text", String.self),
    .field("language", Int?.self),
  ] }

  /// Content of a pre tag
  public var text: String { __data["text"] }
  /// Assuming the codeblock was a programming language, this field is used to identify it.
  public var language: Int? { __data["language"] }
}
