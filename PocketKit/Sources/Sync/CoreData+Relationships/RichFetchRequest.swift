// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData

/// An enhanced `NSFetchRequest` that has extra functionality.
public final class RichFetchRequest<ResultType>: NSFetchRequest<NSFetchRequestResult> where ResultType: NSFetchRequestResult {
    /// A set of relationship key paths to observe when using a `RichFetchedResultsController`.
    public var relationshipKeyPathsForRefreshing: Set<String> = []
}
