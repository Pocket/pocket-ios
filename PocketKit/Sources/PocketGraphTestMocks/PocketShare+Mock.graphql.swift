// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class PocketShare: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.PocketShare
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<PocketShare>>

  public struct MockFields {
    @Field<PocketMetadata>("preview") public var preview
    @Field<PocketGraph.ValidUrl>("shareUrl") public var shareUrl
    @Field<PocketGraph.ID>("slug") public var slug
    @Field<PocketGraph.ValidUrl>("targetUrl") public var targetUrl
  }
}

public extension Mock where O == PocketShare {
  convenience init(
    preview: AnyMock? = nil,
    shareUrl: PocketGraph.ValidUrl? = nil,
    slug: PocketGraph.ID? = nil,
    targetUrl: PocketGraph.ValidUrl? = nil
  ) {
    self.init()
    _setEntity(preview, for: \.preview)
    _setScalar(shareUrl, for: \.shareUrl)
    _setScalar(slug, for: \.slug)
    _setScalar(targetUrl, for: \.targetUrl)
  }
}
