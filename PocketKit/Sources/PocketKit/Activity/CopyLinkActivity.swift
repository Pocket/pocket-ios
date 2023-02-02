// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class CopyLinkActivity: UIActivity {
    private var link: URL?

    static override var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return .copyLink
    }

    override var activityTitle: String? {
        return "Copy link".localized()
    }

    override var activityImage: UIImage? {
        return UIImage(systemName: "link")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        let first = activityItems.first(where: { $0 is URL })
        return first != nil
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        guard let link = activityItems.first(where: { $0 is URL }) as? URL else {
            return
        }

        self.link = link
    }

    override func perform() {
        UIPasteboard.general.url = link
    }
}
