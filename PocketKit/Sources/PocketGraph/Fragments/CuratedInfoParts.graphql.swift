// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct CuratedInfoParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment CuratedInfoParts on CuratedInfo { __typename excerpt imageSrc title }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CuratedInfo }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("excerpt", String?.self),
    .field("imageSrc", PocketGraph.Url?.self),
    .field("title", String?.self),
  ] }

  public var excerpt: String? { __data["excerpt"] }
  public var imageSrc: PocketGraph.Url? { __data["imageSrc"] }
  public var title: String? { __data["title"] }

  public init(
    excerpt: String? = nil,
    imageSrc: PocketGraph.Url? = nil,
    title: String? = nil
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": PocketGraph.Objects.CuratedInfo.typename,
        "excerpt": excerpt,
        "imageSrc": imageSrc,
        "title": title,
      ],
      fulfilledFragments: [
        ObjectIdentifier(CuratedInfoParts.self)
      ]
    ))
  }
}
