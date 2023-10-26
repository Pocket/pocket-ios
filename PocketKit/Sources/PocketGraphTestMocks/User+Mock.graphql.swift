// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class User: MockObject {
  public static let objectType: Object = PocketGraph.Objects.User
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<User>>

  public struct MockFields {
    @Field<String>("email") public var email
    @Field<Bool>("isPremium") public var isPremium
    @Field<String>("name") public var name
    @available(*, deprecated, message: "Use saveById instead")
    @Field<SavedItem>("savedItemById") public var savedItemById
    @Field<SavedItemConnection>("savedItems") public var savedItems
    @Field<SavedItemSearchResultConnection>("searchSavedItems") public var searchSavedItems
    @Field<TagConnection>("tags") public var tags
    @Field<String>("username") public var username
  }
}

public extension Mock where O == User {
  convenience init(
    email: String? = nil,
    isPremium: Bool? = nil,
    name: String? = nil,
    savedItemById: Mock<SavedItem>? = nil,
    savedItems: Mock<SavedItemConnection>? = nil,
    searchSavedItems: Mock<SavedItemSearchResultConnection>? = nil,
    tags: Mock<TagConnection>? = nil,
    username: String? = nil
  ) {
    self.init()
    _setScalar(email, for: \.email)
    _setScalar(isPremium, for: \.isPremium)
    _setScalar(name, for: \.name)
    _setEntity(savedItemById, for: \.savedItemById)
    _setEntity(savedItems, for: \.savedItems)
    _setEntity(searchSavedItems, for: \.searchSavedItems)
    _setEntity(tags, for: \.tags)
    _setScalar(username, for: \.username)
  }
}
