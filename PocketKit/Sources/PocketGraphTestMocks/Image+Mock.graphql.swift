// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Image: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Image
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
    width: Int? = nil
  ) {
    self.init()
    self.caption = caption
    self.credit = credit
    self.height = height
    self.imageID = imageID
    self.imageId = imageId
    self.src = src
    self.width = width
  }
}
