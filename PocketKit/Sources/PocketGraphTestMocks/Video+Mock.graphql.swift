// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Video: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Video
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Video>>

  public struct MockFields {
    @Field<Int>("height") public var height
    @Field<Int>("length") public var length
    @Field<String>("src") public var src
    @Field<GraphQLEnum<PocketGraph.VideoType>>("type") public var type
    @Field<String>("vid") public var vid
    @Field<Int>("videoID") public var videoID
    @Field<Int>("width") public var width
  }
}

public extension Mock where O == Video {
  convenience init(
    height: Int? = nil,
    length: Int? = nil,
    src: String? = nil,
    type: GraphQLEnum<PocketGraph.VideoType>? = nil,
    vid: String? = nil,
    videoID: Int? = nil,
    width: Int? = nil
  ) {
    self.init()
    _set(height, for: \.height)
    _set(length, for: \.length)
    _set(src, for: \.src)
    _set(type, for: \.type)
    _set(vid, for: \.vid)
    _set(videoID, for: \.videoID)
    _set(width, for: \.width)
  }
}
