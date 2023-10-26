// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class NumberedListElement: MockObject {
  public static let objectType: Object = PocketGraph.Objects.NumberedListElement
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<NumberedListElement>>

  public struct MockFields {
    @Field<PocketGraph.Markdown>("content") public var content
    @Field<Int>("index") public var index
    @Field<Int>("level") public var level
  }
}

public extension Mock where O == NumberedListElement {
  convenience init(
    content: PocketGraph.Markdown? = nil,
    index: Int? = nil,
    level: Int? = nil
  ) {
    self.init()
    _setScalar(content, for: \.content)
    _setScalar(index, for: \.index)
    _setScalar(level, for: \.level)
  }
}
