// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Highlight: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Highlight
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Highlight>>

  public struct MockFields {
    @Field<PocketGraph.ID>("id") public var id
    @Field<String>("patch") public var patch
    @Field<String>("quote") public var quote
  }
}

public extension Mock where O == Highlight {
  convenience init(
    id: PocketGraph.ID? = nil,
    patch: String? = nil,
    quote: String? = nil
  ) {
    self.init()
    self.id = id
    self.patch = patch
    self.quote = quote
  }
}
