// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import CoreData

extension Highlight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Highlight> {
        return NSFetchRequest<Highlight>(entityName: "Highlight")
    }

    @NSManaged public var id: String?
    @NSManaged public var patch: String?
    @NSManaged public var quote: String?
    @NSManaged public var annotations: Annotations?

}
