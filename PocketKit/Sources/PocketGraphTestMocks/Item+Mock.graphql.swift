// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Item: MockObject {
  public static let objectType: Object = PocketGraph.Objects.Item
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Item>>

  public struct MockFields {
    @Field<[Author?]>("authors") public var authors
    @Field<Collection>("collection") public var collection
    @Field<PocketGraph.DateString>("datePublished") public var datePublished
    @Field<String>("domain") public var domain
    @Field<DomainMetadata>("domainMetadata") public var domainMetadata
    @Field<String>("excerpt") public var excerpt
    @Field<PocketGraph.Url>("givenUrl") public var givenUrl
    @Field<GraphQLEnum<PocketGraph.Imageness>>("hasImage") public var hasImage
    @Field<GraphQLEnum<PocketGraph.Videoness>>("hasVideo") public var hasVideo
    @Field<[Image?]>("images") public var images
    @Field<Bool>("isArticle") public var isArticle
    @Field<String>("language") public var language
    @Field<[MarticleComponent]>("marticle") public var marticle
    @Field<String>("remoteID") public var remoteID
    @Field<PocketGraph.Url>("resolvedUrl") public var resolvedUrl
    @Field<SyndicatedArticle>("syndicatedArticle") public var syndicatedArticle
    @Field<Int>("timeToRead") public var timeToRead
    @Field<String>("title") public var title
    @available(*, deprecated, message: "use the topImage object")
    @Field<PocketGraph.Url>("topImageUrl") public var topImageUrl
    @Field<Int>("wordCount") public var wordCount
  }
}

public extension Mock where O == Item {
  convenience init(
    authors: [Mock<Author>?]? = nil,
    collection: Mock<Collection>? = nil,
    datePublished: PocketGraph.DateString? = nil,
    domain: String? = nil,
    domainMetadata: Mock<DomainMetadata>? = nil,
    excerpt: String? = nil,
    givenUrl: PocketGraph.Url? = nil,
    hasImage: GraphQLEnum<PocketGraph.Imageness>? = nil,
    hasVideo: GraphQLEnum<PocketGraph.Videoness>? = nil,
    images: [Mock<Image>?]? = nil,
    isArticle: Bool? = nil,
    language: String? = nil,
    marticle: [AnyMock]? = nil,
    remoteID: String? = nil,
    resolvedUrl: PocketGraph.Url? = nil,
    syndicatedArticle: Mock<SyndicatedArticle>? = nil,
    timeToRead: Int? = nil,
    title: String? = nil,
    topImageUrl: PocketGraph.Url? = nil,
    wordCount: Int? = nil
  ) {
    self.init()
    _set(authors, for: \.authors)
    _set(collection, for: \.collection)
    _set(datePublished, for: \.datePublished)
    _set(domain, for: \.domain)
    _set(domainMetadata, for: \.domainMetadata)
    _set(excerpt, for: \.excerpt)
    _set(givenUrl, for: \.givenUrl)
    _set(hasImage, for: \.hasImage)
    _set(hasVideo, for: \.hasVideo)
    _set(images, for: \.images)
    _set(isArticle, for: \.isArticle)
    _set(language, for: \.language)
    _set(marticle, for: \.marticle)
    _set(remoteID, for: \.remoteID)
    _set(resolvedUrl, for: \.resolvedUrl)
    _set(syndicatedArticle, for: \.syndicatedArticle)
    _set(timeToRead, for: \.timeToRead)
    _set(title, for: \.title)
    _set(topImageUrl, for: \.topImageUrl)
    _set(wordCount, for: \.wordCount)
  }
}
