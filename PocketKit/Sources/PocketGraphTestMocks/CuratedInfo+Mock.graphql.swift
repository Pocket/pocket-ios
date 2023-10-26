// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CuratedInfo: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CuratedInfo
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CuratedInfo>>

  public struct MockFields {
    @Field<String>("excerpt") public var excerpt
    @Field<PocketGraph.Url>("imageSrc") public var imageSrc
    @Field<String>("title") public var title
  }
}

public extension Mock where O == CuratedInfo {
  convenience init(
    excerpt: String? = nil,
    imageSrc: PocketGraph.Url? = nil,
    title: String? = nil
  ) {
    self.init()
    _setScalar(excerpt, for: \.excerpt)
    _setScalar(imageSrc, for: \.imageSrc)
    _setScalar(title, for: \.title)
  }
}
