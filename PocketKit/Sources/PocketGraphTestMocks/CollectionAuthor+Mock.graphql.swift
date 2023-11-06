// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CollectionAuthor: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.CollectionAuthor
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CollectionAuthor>>

  public struct MockFields {
    @Field<String>("name") public var name
  }
}

public extension Mock where O == CollectionAuthor {
  convenience init(
    name: String? = nil
  ) {
    self.init()
    _setScalar(name, for: \.name)
  }
}
