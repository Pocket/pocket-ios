// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == PocketGraph.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == PocketGraph.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == PocketGraph.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == PocketGraph.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return PocketGraph.Objects.Query
    case "User": return PocketGraph.Objects.User
    case "SavedItemConnection": return PocketGraph.Objects.SavedItemConnection
    case "PageInfo": return PocketGraph.Objects.PageInfo
    case "SavedItemEdge": return PocketGraph.Objects.SavedItemEdge
    case "SavedItem": return PocketGraph.Objects.SavedItem
    case "Tag": return PocketGraph.Objects.Tag
    case "PendingItem": return PocketGraph.Objects.PendingItem
    case "Item": return PocketGraph.Objects.Item
    case "Author": return PocketGraph.Objects.Author
    case "DomainMetadata": return PocketGraph.Objects.DomainMetadata
    case "Image": return PocketGraph.Objects.Image
    case "SyndicatedArticle": return PocketGraph.Objects.SyndicatedArticle
    case "Publisher": return PocketGraph.Objects.Publisher
    case "SlateLineup": return PocketGraph.Objects.SlateLineup
    case "Slate": return PocketGraph.Objects.Slate
    case "Recommendation": return PocketGraph.Objects.Recommendation
    case "CuratedInfo": return PocketGraph.Objects.CuratedInfo
    case "MarticleText": return PocketGraph.Objects.MarticleText
    case "MarticleDivider": return PocketGraph.Objects.MarticleDivider
    case "MarticleTable": return PocketGraph.Objects.MarticleTable
    case "MarticleHeading": return PocketGraph.Objects.MarticleHeading
    case "MarticleCodeBlock": return PocketGraph.Objects.MarticleCodeBlock
    case "Video": return PocketGraph.Objects.Video
    case "MarticleBulletedList": return PocketGraph.Objects.MarticleBulletedList
    case "MarticleNumberedList": return PocketGraph.Objects.MarticleNumberedList
    case "MarticleBlockquote": return PocketGraph.Objects.MarticleBlockquote
    case "UnMarseable": return PocketGraph.Objects.UnMarseable
    case "BulletedListElement": return PocketGraph.Objects.BulletedListElement
    case "NumberedListElement": return PocketGraph.Objects.NumberedListElement
    case "Mutation": return PocketGraph.Objects.Mutation
    case "TagConnection": return PocketGraph.Objects.TagConnection
    case "TagEdge": return PocketGraph.Objects.TagEdge
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
