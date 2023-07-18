// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CorpusItem: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CorpusItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CorpusItem>>

  public struct MockFields {
    @Field<String>("excerpt") public var excerpt
    @Field<PocketGraph.ID>("id") public var id
    @Field<PocketGraph.Url>("imageUrl") public var imageUrl
    @Field<String>("publisher") public var publisher
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
    target: AnyMock? = nil,
    title: String? = nil,
    url: PocketGraph.Url? = nil
  ) {
    self.init()
    _set(excerpt, for: \.excerpt)
    _set(id, for: \.id)
    _set(imageUrl, for: \.imageUrl)
    _set(publisher, for: \.publisher)
    _set(target, for: \.target)
    _set(title, for: \.title)
    _set(url, for: \.url)
  }
}
