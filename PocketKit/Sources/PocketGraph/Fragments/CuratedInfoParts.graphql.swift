// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CuratedInfoParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment CuratedInfoParts on CuratedInfo {
      __typename
      excerpt
      imageSrc
      title
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.CuratedInfo }
  public static var __selections: [Selection] { [
    .field("excerpt", String?.self),
    .field("imageSrc", Url?.self),
    .field("title", String?.self),
  ] }

  public var excerpt: String? { __data["excerpt"] }
  public var imageSrc: Url? { __data["imageSrc"] }
  public var title: String? { __data["title"] }
}
