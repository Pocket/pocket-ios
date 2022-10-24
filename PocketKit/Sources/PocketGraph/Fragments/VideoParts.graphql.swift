// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct VideoParts: PocketGraph.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString { """
    fragment VideoParts on Video {
      __typename
      height
      src
      type
      vid
      videoID: videoId
      width
      length
    }
    """ }

  public let __data: DataDict
  public init(data: DataDict) { __data = data }

  public static var __parentType: ParentType { PocketGraph.Objects.Video }
  public static var __selections: [Selection] { [
    .field("height", Int?.self),
    .field("src", String.self),
    .field("type", GraphQLEnum<VideoType>.self),
    .field("vid", String?.self),
    .field("videoId", alias: "videoID", Int.self),
    .field("width", Int?.self),
    .field("length", Int?.self),
  ] }

  /// If known, the height of the video in px
  public var height: Int? { __data["height"] }
  /// Absolute url to the video
  public var src: String { __data["src"] }
  /// The type of video
  public var type: GraphQLEnum<VideoType> { __data["type"] }
  /// The video's id within the service defined by type
  public var vid: String? { __data["vid"] }
  /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
  public var videoID: Int { __data["videoID"] }
  /// If known, the width of the video in px
  public var width: Int? { __data["width"] }
  /// If known, the length of the video in seconds
  public var length: Int? { __data["length"] }
}
