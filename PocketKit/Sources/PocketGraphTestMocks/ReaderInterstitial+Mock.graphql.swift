// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class ReaderInterstitial: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.ReaderInterstitial
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ReaderInterstitial>>

  public struct MockFields {
    @Field<PocketMetadata>("itemCard") public var itemCard
  }
}

public extension Mock where O == ReaderInterstitial {
  convenience init(
    itemCard: AnyMock? = nil
  ) {
    self.init()
    _setEntity(itemCard, for: \.itemCard)
  }
}
