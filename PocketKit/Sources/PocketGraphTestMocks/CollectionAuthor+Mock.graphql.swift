// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class CollectionAuthor: MockObject {
  public static let objectType: Object = PocketGraph.Objects.CollectionAuthor
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<CollectionAuthor>>

  public struct MockFields {
    @Field<PocketGraph.Markdown>("bio") public var bio
    @Field<PocketGraph.Url>("imageUrl") public var imageUrl
    @Field<String>("name") public var name
  }
}

public extension Mock where O == CollectionAuthor {
  convenience init(
    bio: PocketGraph.Markdown? = nil,
    imageUrl: PocketGraph.Url? = nil,
    name: String? = nil
  ) {
    self.init()
    _set(bio, for: \.bio)
    _set(imageUrl, for: \.imageUrl)
    _set(name, for: \.name)
  }
}
