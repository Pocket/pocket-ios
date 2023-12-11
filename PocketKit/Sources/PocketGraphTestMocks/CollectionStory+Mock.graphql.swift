// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CollectionStory: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.CollectionStory
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CollectionStory>>

  public struct MockFields {
    @Field<[CollectionStoryAuthor]>("authors") public var authors
    @Field<PocketGraph.Markdown>("excerpt") public var excerpt
    @Field<PocketGraph.Url>("imageUrl") public var imageUrl
    @Field<Item>("item") public var item
    @Field<String>("publisher") public var publisher
    @Field<Int>("sortOrder") public var sortOrder
    @Field<String>("title") public var title
    @Field<PocketGraph.Url>("url") public var url
  }
}

public extension Mock where O == CollectionStory {
  convenience init(
    authors: [Mock<CollectionStoryAuthor>]? = nil,
    excerpt: PocketGraph.Markdown? = nil,
    imageUrl: PocketGraph.Url? = nil,
    item: Mock<Item>? = nil,
    publisher: String? = nil,
    sortOrder: Int? = nil,
    title: String? = nil,
    url: PocketGraph.Url? = nil
  ) {
    self.init()
    _setList(authors, for: \.authors)
    _setScalar(excerpt, for: \.excerpt)
    _setScalar(imageUrl, for: \.imageUrl)
    _setEntity(item, for: \.item)
    _setScalar(publisher, for: \.publisher)
    _setScalar(sortOrder, for: \.sortOrder)
    _setScalar(title, for: \.title)
    _setScalar(url, for: \.url)
  }
}
