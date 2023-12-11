// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

/// Helper class to always show a share sheet via a modal
/// https://stackoverflow.com/questions/67568525/display-uiactivityviewcontroller-as-form-sheet-on-ipad
class ShareSheetController: UIViewController {
    private let activityController: UIActivityViewController

    init(activity: PocketActivity, completion: UIActivityViewController.CompletionWithItemsHandler?) {
        self.activityController = UIActivityViewController(activity: activity)
        self.activityController.completionWithItemsHandler = { one, two, three, four in
            guard let completion else { return }
            completion(one, two, three, four)
        }

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .formSheet // or pageSheet
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(activityController)
        view.addSubview(activityController.view)

        activityController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityController.view.topAnchor.constraint(equalTo: view.topAnchor),
            activityController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
