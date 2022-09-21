//
//  File.swift
//  
//
//  Created by Daniel Brooks on 9/20/22.
//

import Foundation
import UIKit

public class Device {

    // static property to create singleton
    public static let current = Device()

    public func deviceIdentifer() -> String {
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            // TODO: Save this string off into the keychain
            return UUID().uuidString
        }

        return identifierForVendor.uuidString

    }

}
