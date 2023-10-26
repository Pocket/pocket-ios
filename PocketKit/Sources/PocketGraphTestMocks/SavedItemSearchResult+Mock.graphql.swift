// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemSearchResult: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SavedItemSearchResult
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItemSearchResult>>

  public struct MockFields {
    @Field<SavedItem>("savedItem") public var savedItem
  }
}

public extension Mock where O == SavedItemSearchResult {
  convenience init(
    savedItem: Mock<SavedItem>? = nil
  ) {
    self.init()
    _setEntity(savedItem, for: \.savedItem)
  }
}
