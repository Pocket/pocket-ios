import UIKit
import Analytics
import Sync


class MainCoordinator {
    var viewController: UIViewController {
        regular.viewController
    }

    private let compact: CompactMainCoordinator
    private let regular: RegularMainCoordinator

    init(
        model: MainViewModel,
        source: Source,
        tracker: Tracker
    ) {
        compact = CompactMainCoordinator(
            source: source,
            tracker: tracker,
            model: model
        )

        regular = RegularMainCoordinator(
            source: source,
            tracker: tracker,
            model: model
        )

        regular.setCompactViewController(compact.viewController)
    }

    func showList() {
        regular.showSupplementary()
    }
}
