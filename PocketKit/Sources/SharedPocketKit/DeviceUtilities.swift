//
//  File.swift
//  
//
//  Created by Daniel Brooks on 9/20/22.
//

import Foundation
import UIKit

public class DeviceUtilities {

    enum Error: Swift.Error {
        case idfvUnavailable
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
