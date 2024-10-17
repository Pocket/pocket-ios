// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class OEmbed: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.OEmbed
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<OEmbed>>

  public struct MockFields {
    @Field<[Author]>("authors") public var authors
    @Field<PocketGraph.ISOString>("datePublished") public var datePublished
    @Field<DomainMetadata>("domain") public var domain
    @Field<String>("excerpt") public var excerpt
    @Field<PocketGraph.ID>("id") public var id
    @Field<Image>("image") public var image
    @Field<Item>("item") public var item
    @Field<String>("title") public var title
    @Field<PocketGraph.Url>("url") public var url
  }
}

public extension Mock where O == OEmbed {
  convenience init(
    authors: [Mock<Author>]? = nil,
    datePublished: PocketGraph.ISOString? = nil,
    domain: Mock<DomainMetadata>? = nil,
    excerpt: String? = nil,
    id: PocketGraph.ID? = nil,
    image: Mock<Image>? = nil,
    item: Mock<Item>? = nil,
    title: String? = nil,
    url: PocketGraph.Url? = nil
  ) {
    self.init()
    _setList(authors, for: \.authors)
    _setScalar(datePublished, for: \.datePublished)
    _setEntity(domain, for: \.domain)
    _setScalar(excerpt, for: \.excerpt)
    _setScalar(id, for: \.id)
    _setEntity(image, for: \.image)
    _setEntity(item, for: \.item)
    _setScalar(title, for: \.title)
    _setScalar(url, for: \.url)
  }
}
