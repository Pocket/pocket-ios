// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Image: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Image
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Image>>

  public struct MockFields {
    @Field<String>("caption") public var caption
    @Field<String>("credit") public var credit
    @Field<Int>("height") public var height
    @Field<Int>("imageID") public var imageID
    @Field<Int>("imageId") public var imageId
    @available(*, deprecated, message: "use url property moving forward")
    @Field<String>("src") public var src
    @Field<PocketGraph.Url>("url") public var url
    @Field<Int>("width") public var width
  }
}

public extension Mock where O == Image {
  convenience init(
    caption: String? = nil,
    credit: String? = nil,
    height: Int? = nil,
    imageID: Int? = nil,
    imageId: Int? = nil,
    src: String? = nil,
    url: PocketGraph.Url? = nil,
    width: Int? = nil
  ) {
    self.init()
    _setScalar(caption, for: \.caption)
    _setScalar(credit, for: \.credit)
    _setScalar(height, for: \.height)
    _setScalar(imageID, for: \.imageID)
    _setScalar(imageId, for: \.imageId)
    _setScalar(src, for: \.src)
    _setScalar(url, for: \.url)
    _setScalar(width, for: \.width)
  }
}
