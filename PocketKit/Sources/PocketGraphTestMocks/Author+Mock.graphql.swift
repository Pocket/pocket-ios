// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Author: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Author
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Author>>

  public struct MockFields {
    @Field<PocketGraph.ID>("id") public var id
    @Field<String>("name") public var name
    @Field<String>("url") public var url
  }
}

public extension Mock where O == Author {
  convenience init(
    id: PocketGraph.ID? = nil,
    name: String? = nil,
    url: String? = nil
  ) {
    self.init()
    _set(id, for: \.id)
    _set(name, for: \.name)
    _set(url, for: \.url)
  }
}
