// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemSearchResultEdge: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SavedItemSearchResultEdge
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItemSearchResultEdge>>

  public struct MockFields {
    @Field<String>("cursor") public var cursor
    @Field<SavedItemSearchResult>("node") public var node
  }
}

public extension Mock where O == SavedItemSearchResultEdge {
  convenience init(
    cursor: String? = nil,
    node: Mock<SavedItemSearchResult>? = nil
  ) {
    self.init()
    _setScalar(cursor, for: \.cursor)
    _setEntity(node, for: \.node)
  }
}
