// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class BulletedListElement: MockObject {
  public static let objectType: Object = PocketGraph.Objects.BulletedListElement
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<BulletedListElement>>

  public struct MockFields {
    @Field<PocketGraph.Markdown>("content") public var content
    @Field<Int>("level") public var level
  }
}

public extension Mock where O == BulletedListElement {
  convenience init(
    content: PocketGraph.Markdown? = nil,
    level: Int? = nil
  ) {
    self.init()
    _setScalar(content, for: \.content)
    _setScalar(level, for: \.level)
  }
}
