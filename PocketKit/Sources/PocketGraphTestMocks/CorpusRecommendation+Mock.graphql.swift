// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CorpusRecommendation: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CorpusRecommendation
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CorpusRecommendation>>

  public struct MockFields {
    @Field<CorpusItem>("corpusItem") public var corpusItem
    @Field<PocketGraph.ID>("id") public var id
  }
}

public extension Mock where O == CorpusRecommendation {
  convenience init(
    corpusItem: Mock<CorpusItem>? = nil,
    id: PocketGraph.ID? = nil
  ) {
    self.init()
    _setEntity(corpusItem, for: \.corpusItem)
    _setScalar(id, for: \.id)
  }
}
