// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Item: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Item
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Item>>

  public struct MockFields {
    @Field<Collection>("collection") public var collection
    @Field<PocketGraph.Url>("givenUrl") public var givenUrl
    @Field<GraphQLEnum<PocketGraph.Imageness>>("hasImage") public var hasImage
    @Field<GraphQLEnum<PocketGraph.Videoness>>("hasVideo") public var hasVideo
    @Field<PocketGraph.ID>("id") public var id
    @Field<[Image?]>("images") public var images
    @Field<Bool>("isArticle") public var isArticle
    @Field<String>("language") public var language
    @Field<[MarticleComponent]>("marticle") public var marticle
    @Field<String>("normalUrl") public var normalUrl
    @Field<PocketMetadata>("preview") public var preview
    @Field<String>("remoteID") public var remoteID
    @Field<PocketGraph.Url>("resolvedUrl") public var resolvedUrl
    @Field<SavedItem>("savedItem") public var savedItem
    @Field<SyndicatedArticle>("syndicatedArticle") public var syndicatedArticle
    @Field<Int>("timeToRead") public var timeToRead
    @Field<Int>("wordCount") public var wordCount
  }
}

public extension Mock where O == Item {
  convenience init(
    collection: Mock<Collection>? = nil,
    givenUrl: PocketGraph.Url? = nil,
    hasImage: GraphQLEnum<PocketGraph.Imageness>? = nil,
    hasVideo: GraphQLEnum<PocketGraph.Videoness>? = nil,
    id: PocketGraph.ID? = nil,
    images: [Mock<Image>?]? = nil,
    isArticle: Bool? = nil,
    language: String? = nil,
    marticle: [AnyMock]? = nil,
    normalUrl: String? = nil,
    preview: AnyMock? = nil,
    remoteID: String? = nil,
    resolvedUrl: PocketGraph.Url? = nil,
    savedItem: Mock<SavedItem>? = nil,
    syndicatedArticle: Mock<SyndicatedArticle>? = nil,
    timeToRead: Int? = nil,
    wordCount: Int? = nil
  ) {
    self.init()
    _setEntity(collection, for: \.collection)
    _setScalar(givenUrl, for: \.givenUrl)
    _setScalar(hasImage, for: \.hasImage)
    _setScalar(hasVideo, for: \.hasVideo)
    _setScalar(id, for: \.id)
    _setList(images, for: \.images)
    _setScalar(isArticle, for: \.isArticle)
    _setScalar(language, for: \.language)
    _setList(marticle, for: \.marticle)
    _setScalar(normalUrl, for: \.normalUrl)
    _setEntity(preview, for: \.preview)
    _setScalar(remoteID, for: \.remoteID)
    _setScalar(resolvedUrl, for: \.resolvedUrl)
    _setEntity(savedItem, for: \.savedItem)
    _setEntity(syndicatedArticle, for: \.syndicatedArticle)
    _setScalar(timeToRead, for: \.timeToRead)
    _setScalar(wordCount, for: \.wordCount)
  }
}
