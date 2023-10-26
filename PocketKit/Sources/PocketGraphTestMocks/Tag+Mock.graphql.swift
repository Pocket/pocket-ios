// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Tag: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Tag
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Tag>>

  public struct MockFields {
    @Field<PocketGraph.ID>("id") public var id
    @Field<String>("name") public var name
  }
}

public extension Mock where O == Tag {
  convenience init(
    id: PocketGraph.ID? = nil,
    name: String? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
  }
}
