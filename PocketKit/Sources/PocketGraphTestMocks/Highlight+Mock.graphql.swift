// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Highlight: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Highlight
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Highlight>>

  public struct MockFields {
    @Field<PocketGraph.Timestamp>("_createdAt") public var _createdAt
    @Field<PocketGraph.Timestamp>("_updatedAt") public var _updatedAt
    @Field<PocketGraph.ID>("id") public var id
    @Field<String>("patch") public var patch
    @Field<String>("quote") public var quote
    @Field<Int>("version") public var version
  }
}

public extension Mock where O == Highlight {
  convenience init(
    _createdAt: PocketGraph.Timestamp? = nil,
    _updatedAt: PocketGraph.Timestamp? = nil,
    id: PocketGraph.ID? = nil,
    patch: String? = nil,
    quote: String? = nil,
    version: Int? = nil
  ) {
    self.init()
    _setScalar(_createdAt, for: \._createdAt)
    _setScalar(_updatedAt, for: \._updatedAt)
    _setScalar(id, for: \.id)
    _setScalar(patch, for: \.patch)
    _setScalar(quote, for: \.quote)
    _setScalar(version, for: \.version)
  }
}
