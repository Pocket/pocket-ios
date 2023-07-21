// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Collection: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Collection
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Collection>>

  public struct MockFields {
    @Field<[CollectionAuthor]>("authors") public var authors
    @Field<PocketGraph.ID>("externalId") public var externalId
    @Field<PocketGraph.Markdown>("intro") public var intro
    @Field<PocketGraph.DateString>("publishedAt") public var publishedAt
    @Field<String>("slug") public var slug
    @Field<[CollectionStory]>("stories") public var stories
    @Field<String>("title") public var title
  }
}

public extension Mock where O == Collection {
  convenience init(
    authors: [Mock<CollectionAuthor>]? = nil,
    externalId: PocketGraph.ID? = nil,
    intro: PocketGraph.Markdown? = nil,
    publishedAt: PocketGraph.DateString? = nil,
    slug: String? = nil,
    stories: [Mock<CollectionStory>]? = nil,
    title: String? = nil
  ) {
    self.init()
    _set(authors, for: \.authors)
    _set(externalId, for: \.externalId)
    _set(intro, for: \.intro)
    _set(publishedAt, for: \.publishedAt)
    _set(slug, for: \.slug)
    _set(stories, for: \.stories)
    _set(title, for: \.title)
  }
}
