// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class Query: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.Query
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Query>>

  public struct MockFields {
    @Field<UnleashAssignmentList>("assignments") public var assignments
    @Field<Collection>("collection") public var collection
    @available(*, deprecated, message: "Please use queries specific to the surface ex. setMomentSlate. If a named query for your surface does not yet exit please reach out to the Data Products team and they will happily provide you with a named query.")
    @Field<Slate>("getSlate") public var getSlate
    @available(*, deprecated, message: "Please use queries specific to the surface ex. setMomentSlate. If a named query for your surface does not yet exit please reach out to the Data Products team and they will happily provide you with a named query.")
    @Field<SlateLineup>("getSlateLineup") public var getSlateLineup
    @Field<CorpusSlateLineup>("homeSlateLineup") public var homeSlateLineup
    @Field<Item>("itemByUrl") public var itemByUrl
    @Field<ReaderViewResult>("readerSlug") public var readerSlug
    @Field<ShareResult>("shareSlug") public var shareSlug
    @Field<User>("user") public var user
  }
}

public extension Mock where O == Query {
  convenience init(
    assignments: Mock<UnleashAssignmentList>? = nil,
    collection: Mock<Collection>? = nil,
    getSlate: Mock<Slate>? = nil,
    getSlateLineup: Mock<SlateLineup>? = nil,
    homeSlateLineup: Mock<CorpusSlateLineup>? = nil,
    itemByUrl: Mock<Item>? = nil,
    readerSlug: Mock<ReaderViewResult>? = nil,
    shareSlug: AnyMock? = nil,
    user: Mock<User>? = nil
  ) {
    self.init()
    _setEntity(assignments, for: \.assignments)
    _setEntity(collection, for: \.collection)
    _setEntity(getSlate, for: \.getSlate)
    _setEntity(getSlateLineup, for: \.getSlateLineup)
    _setEntity(homeSlateLineup, for: \.homeSlateLineup)
    _setEntity(itemByUrl, for: \.itemByUrl)
    _setEntity(readerSlug, for: \.readerSlug)
    _setEntity(shareSlug, for: \.shareSlug)
    _setEntity(user, for: \.user)
  }
}
