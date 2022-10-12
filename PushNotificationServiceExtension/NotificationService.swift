// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import BrazeNotificationService
import SharedPocketKit
import UserNotifications

class NotificationService: BrazeNotificationService.NotificationService {

    /**
     Pocket App session to determine if logged in.
     */
    let appSession: AppSession

    override init() {
         appSession = AppSession()
        super.init()
    }

    public override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard let _ = appSession.currentSession else {
            contentHandler(UNNotificationContent())
            return
        }

        //Forward notification request to Braze
        if brazeHandle(request: request, contentHandler: contentHandler) {
         // Braze handled the notification, nothing more to do.
         return
        }

        // Braze did not handle this notification request,
        // manually call the content handler to let the system
        // know that the user notification is processed.
        contentHandler(request.content)
    }
}
