// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class CopyLinkWithSelectionActivity: UIActivity {
    private var link: URL?
    private var highlight: String?

    static override var activityCategory: UIActivity.Category {
        return .action
    }

    override var activityType: UIActivity.ActivityType? {
        return .copySelection
    }

    override var activityTitle: String? {
        return "Copy link with selection".localized()
    }

    override var activityImage: UIImage? {
        return UIImage(systemName: "highlighter")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        let firstURL = activityItems.first(where: { $0 is URL })
        let firstString  = activityItems.first(where: { $0 is String })
        return firstURL != nil && firstString != nil
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        guard let link = activityItems.first(where: { $0 is URL }) as? URL,
        let highlight = activityItems.first(where: { $0 is String }) as? String else {
            return
        }

        self.link = link
        self.highlight = highlight
    }

    override func perform() {
        guard let link = link, let highlight = highlight else {
            return
        }

        let components = [link.absoluteString, "\"\(highlight)\""]
        let string = components.joined(separator: "\n\n")

        UIPasteboard.general.string = string
    }
}
