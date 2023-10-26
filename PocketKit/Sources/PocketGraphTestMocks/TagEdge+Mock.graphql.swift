// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class TagEdge: MockObject {
  public static let objectType: Object = PocketGraph.Objects.TagEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<TagEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<Tag>("node") public var node
  }
}

public extension Mock where O == TagEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<Tag>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
