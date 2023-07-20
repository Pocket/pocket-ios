// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CollectionStoryAuthor: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CollectionStoryAuthor
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CollectionStoryAuthor>>

  public struct MockFields {
    @Field<String>("name") public var name
  }
}

public extension Mock where O == CollectionStoryAuthor {
  convenience init(
    name: String? = nil
  ) {
    self.init()
    _set(name, for: \.name)
  }
}
