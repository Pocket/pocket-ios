// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CorpusSlateLineup: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CorpusSlateLineup
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CorpusSlateLineup>>

  public struct MockFields {
    @Field<PocketGraph.ID>("id") public var id
    @Field<[CorpusSlate]>("slates") public var slates
  }
}

public extension Mock where O == CorpusSlateLineup {
  convenience init(
    id: PocketGraph.ID? = nil,
    slates: [Mock<CorpusSlate>]? = nil
  ) {
    self.init()
    _set(id, for: \.id)
    _set(slates, for: \.slates)
  }
}
