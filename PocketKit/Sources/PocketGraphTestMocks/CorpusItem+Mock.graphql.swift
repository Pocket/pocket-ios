// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CorpusItem: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.CorpusItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CorpusItem>>

  public struct MockFields {
    @Field<String>("excerpt") public var excerpt
    @Field<PocketGraph.ID>("id") public var id
    @Field<PocketGraph.Url>("imageUrl") public var imageUrl
    @Field<String>("publisher") public var publisher
    @Field<PocketGraph.Url>("shortUrl") public var shortUrl
    @Field<CorpusTarget>("target") public var target
    @Field<String>("title") public var title
    @Field<PocketGraph.Url>("url") public var url
  }
}

public extension Mock where O == CorpusItem {
  convenience init(
    excerpt: String? = nil,
    id: PocketGraph.ID? = nil,
    imageUrl: PocketGraph.Url? = nil,
    publisher: String? = nil,
    shortUrl: PocketGraph.Url? = nil,
    target: AnyMock? = nil,
    title: String? = nil,
    url: PocketGraph.Url? = nil
  ) {
    self.init()
    _setScalar(excerpt, for: \.excerpt)
    _setScalar(id, for: \.id)
    _setScalar(imageUrl, for: \.imageUrl)
    _setScalar(publisher, for: \.publisher)
    _setScalar(shortUrl, for: \.shortUrl)
    _setEntity(target, for: \.target)
    _setScalar(title, for: \.title)
    _setScalar(url, for: \.url)
  }
}
