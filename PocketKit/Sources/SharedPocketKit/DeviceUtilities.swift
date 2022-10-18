import Foundation
import UIKit

public class DeviceUtilities {

    enum Error: Swift.Error, LocalizedError {
        case idfvUnavailable

        var errorDescription: String? {
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
