// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SyndicatedArticle: MockObject {
  public static let objectType: Object = PocketGraph.Objects.SyndicatedArticle
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SyndicatedArticle>>

  public struct MockFields {
    @Field<String>("excerpt") public var excerpt
    @Field<PocketGraph.ID>("itemId") public var itemId
    @Field<String>("mainImage") public var mainImage
    @Field<Publisher>("publisher") public var publisher
    @Field<String>("title") public var title
  }
}

public extension Mock where O == SyndicatedArticle {
  convenience init(
    excerpt: String? = nil,
    itemId: PocketGraph.ID? = nil,
    mainImage: String? = nil,
    publisher: Mock<Publisher>? = nil,
    title: String? = nil
  ) {
    self.init()
    _set(excerpt, for: \.excerpt)
    _set(itemId, for: \.itemId)
    _set(mainImage, for: \.mainImage)
    _set(publisher, for: \.publisher)
    _set(title, for: \.title)
  }
}
