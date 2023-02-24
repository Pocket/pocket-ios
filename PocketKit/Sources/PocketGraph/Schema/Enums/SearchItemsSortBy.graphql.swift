// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Enum to specify the sort by field (these are the current options, we could add more in the future)
public enum SearchItemsSortBy: String, EnumType {
  /// Indicates when a SavedItem was created
  case createdAt = "CREATED_AT"
  /// Estimated time to read a SavedItem
  case timeToRead = "TIME_TO_READ"
  /// Sort SavedItems based on a relevance score
  /// This is a feature of elasticsearch and current only available for premium search
  case relevance = "RELEVANCE"
}
