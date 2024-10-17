// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CorpusItem: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.CorpusItem
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CorpusItem>>

  public struct MockFields {
    @Field<PocketGraph.ID>("id") public var id
    @Field<PocketGraph.Url>("imageUrl") public var imageUrl
    @Field<PocketMetadata>("preview") public var preview
    @Field<String>("publisher") public var publisher
    @Field<CorpusTarget>("target") public var target
    @Field<Int>("timeToRead") public var timeToRead
    @Field<PocketGraph.Url>("url") public var url
  }
}

public extension Mock where O == CorpusItem {
  convenience init(
    id: PocketGraph.ID? = nil,
    imageUrl: PocketGraph.Url? = nil,
    preview: AnyMock? = nil,
    publisher: String? = nil,
    target: AnyMock? = nil,
    timeToRead: Int? = nil,
    url: PocketGraph.Url? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setScalar(imageUrl, for: \.imageUrl)
    _setEntity(preview, for: \.preview)
    _setScalar(publisher, for: \.publisher)
    _setEntity(target, for: \.target)
    _setScalar(timeToRead, for: \.timeToRead)
    _setScalar(url, for: \.url)
  }
}
