// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Item: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Item
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
    @Field<SavedItem>("savedItem") public var savedItem
    @Field<PocketGraph.Url>("shortUrl") public var shortUrl
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
    savedItem: Mock<SavedItem>? = nil,
    shortUrl: PocketGraph.Url? = nil,
    syndicatedArticle: Mock<SyndicatedArticle>? = nil,
    timeToRead: Int? = nil,
    title: String? = nil,
    topImageUrl: PocketGraph.Url? = nil,
    wordCount: Int? = nil
  ) {
    self.init()
    _setList(authors, for: \.authors)
    _setEntity(collection, for: \.collection)
    _setScalar(datePublished, for: \.datePublished)
    _setScalar(domain, for: \.domain)
    _setEntity(domainMetadata, for: \.domainMetadata)
    _setScalar(excerpt, for: \.excerpt)
    _setScalar(givenUrl, for: \.givenUrl)
    _setScalar(hasImage, for: \.hasImage)
    _setScalar(hasVideo, for: \.hasVideo)
    _setList(images, for: \.images)
    _setScalar(isArticle, for: \.isArticle)
    _setScalar(language, for: \.language)
    _setList(marticle, for: \.marticle)
    _setScalar(remoteID, for: \.remoteID)
    _setScalar(resolvedUrl, for: \.resolvedUrl)
    _setEntity(savedItem, for: \.savedItem)
    _setScalar(shortUrl, for: \.shortUrl)
    _setEntity(syndicatedArticle, for: \.syndicatedArticle)
    _setScalar(timeToRead, for: \.timeToRead)
    _setScalar(title, for: \.title)
    _setScalar(topImageUrl, for: \.topImageUrl)
    _setScalar(wordCount, for: \.wordCount)
  }
}
