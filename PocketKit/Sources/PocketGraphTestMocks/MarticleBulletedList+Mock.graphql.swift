// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleBulletedList: MockObject {
  public static let objectType: Object = PocketGraph.Objects.MarticleBulletedList
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleBulletedList>>

  public struct MockFields {
    @Field<[BulletedListElement]>("rows") public var rows
  }
}

public extension Mock where O == MarticleBulletedList {
  convenience init(
    rows: [Mock<BulletedListElement>]? = nil
  ) {
    self.init()
    _setList(rows, for: \.rows)
  }
}
