// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit

public class DeviceUtilities {
    enum Error: LoggableError {
        case idfvUnavailable

        var logDescription: String {
            switch self {
            case .idfvUnavailable:
                return "IDFV Identifier is currently unavailable"
            }
        }
    }

    /**
     Helper function to catch errors for the IDFV
     This is because the IDFV can be nil at times, but given our current use cases adn online documentation, when we currently fetch it, it should not be nil
     */
    public static func deviceIdentifer() throws -> String {
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            throw DeviceUtilities.Error.idfvUnavailable
        }

        return identifierForVendor.uuidString
    }
}
