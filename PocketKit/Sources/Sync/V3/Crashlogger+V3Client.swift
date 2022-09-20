import Foundation
import Alamofire
import Sentry

extension Crashlogger {

    /**
     Helper function for Crashlogger to ensure that we capture Alamofire errors without crashing to the user.
     */
    public static func capture(error: AFError?) {
        guard let error = error else {
            SentrySDK.capture(message: "There was an Alamofire error, but the error object was empty.")
            return
        }
        SentrySDK.capture(error: error)
    }
}
