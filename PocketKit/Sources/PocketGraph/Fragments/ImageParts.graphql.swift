// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ImageParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment ImageParts on Image {
      __typename
      caption
      credit
      imageID: imageId
      src
      height
      width
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.Image }
  public static var __selections: [Selection] { [
    .field("caption", String?.self),
    .field("credit", String?.self),
    .field("imageId", alias: "imageID", Int.self),
    .field("src", String.self),
    .field("height", Int?.self),
    .field("width", Int?.self),
  ] }

  /// A caption or description of the image
  public var caption: String? { __data["caption"] }
  /// A credit for the image, typically who the image belongs to / created by
  public var credit: String? { __data["credit"] }
  /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
  public var imageID: Int { __data["imageID"] }
  /// Absolute url to the image
  @available(*, deprecated, message: "use url property moving forward")
  public var src: String { __data["src"] }
  /// The determined height of the image at the url
  public var height: Int? { __data["height"] }
  /// The determined width of the image at the url
  public var width: Int? { __data["width"] }
}
