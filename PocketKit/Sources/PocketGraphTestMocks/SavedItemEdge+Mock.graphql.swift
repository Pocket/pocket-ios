// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemEdge: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.SavedItemEdge
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
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
