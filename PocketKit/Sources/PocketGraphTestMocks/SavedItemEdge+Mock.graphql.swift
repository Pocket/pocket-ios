// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemEdge: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SavedItemEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItemEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<SavedItem>("node") public var node
  }
}

public extension Mock where O == SavedItemEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<SavedItem>? = nil
  ) {
    self.init()
    _set(cursor, for: \.cursor)
    _set(node, for: \.node)
  }
}
