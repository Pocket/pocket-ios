// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleNumberedList: MockObject {
  public static let objectType: Object = PocketGraph.Objects.MarticleNumberedList
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleNumberedList>>

  public struct MockFields {
    @Field<[NumberedListElement]>("rows") public var rows
  }
}

public extension Mock where O == MarticleNumberedList {
  convenience init(
    rows: [Mock<NumberedListElement>]? = nil
  ) {
    self.init()
    _setList(rows, for: \.rows)
  }
}
