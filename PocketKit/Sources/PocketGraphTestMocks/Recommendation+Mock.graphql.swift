// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Recommendation: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Recommendation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Recommendation>>

  public struct MockFields {
    @Field<CuratedInfo>("curatedInfo") public var curatedInfo
    @Field<PocketGraph.ID>("id") public var id
    @Field<Item>("item") public var item
  }
}

public extension Mock where O == Recommendation {
  convenience init(
    curatedInfo: Mock<CuratedInfo>? = nil,
    id: PocketGraph.ID? = nil,
    item: Mock<Item>? = nil
  ) {
    self.init()
    _setEntity(curatedInfo, for: \.curatedInfo)
    _setScalar(id, for: \.id)
    _setEntity(item, for: \.item)
  }
}
