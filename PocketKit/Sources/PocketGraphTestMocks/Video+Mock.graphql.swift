// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Video: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Video
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Video>>

  public struct MockFields {
    @Field<Int?>("height") public var height
    @Field<Int?>("length") public var length
    @Field<String>("src") public var src
    @Field<GraphQLEnum<PocketGraph.VideoType>>("type") public var type
    @Field<String?>("vid") public var vid
    @Field<Int>("videoID") public var videoID
    @Field<Int?>("width") public var width
  }
}

public extension Mock where O == Video {
  convenience init(
    height: Int? = nil,
    length: Int? = nil,
    src: String,
    type: GraphQLEnum<PocketGraph.VideoType>,
    vid: String? = nil,
    videoID: Int,
    width: Int? = nil
  ) {
    self.init()
    self.height = height
    self.length = length
    self.src = src
    self.type = type
    self.vid = vid
    self.videoID = videoID
    self.width = width
  }
}
