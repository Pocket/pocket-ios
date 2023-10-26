// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CorpusSlate: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CorpusSlate
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CorpusSlate>>

  public struct MockFields {
    @Field<String>("headline") public var headline
    @Field<PocketGraph.ID>("id") public var id
    @Field<[CorpusRecommendation]>("recommendations") public var recommendations
    @Field<String>("subheadline") public var subheadline
  }
}

public extension Mock where O == CorpusSlate {
  convenience init(
    headline: String? = nil,
    id: PocketGraph.ID? = nil,
    recommendations: [Mock<CorpusRecommendation>]? = nil,
    subheadline: String? = nil
  ) {
    self.init()
    _setScalar(headline, for: \.headline)
    _setScalar(id, for: \.id)
    _setList(recommendations, for: \.recommendations)
    _setScalar(subheadline, for: \.subheadline)
  }
}
