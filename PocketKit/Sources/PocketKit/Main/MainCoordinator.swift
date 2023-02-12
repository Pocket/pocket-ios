import UIKit
import Analytics
import Sync
import Combine
import BackgroundTasks

class MainCoordinator {
    var viewController: UIViewController {
        regular.viewController
    }

    var tabBar: UITabBar? {
        compact.tabBar
    }

    private let compact: CompactMainCoordinator
    private let regular: RegularMainCoordinator

    private var subscriptions: Set<AnyCancellable> = []

    init(
        model: MainViewModel,
        source: Source,
        tracker: Tracker
    ) {
        compact = CompactMainCoordinator(tracker: tracker, model: model)
        regular = RegularMainCoordinator(tracker: tracker, model: model)

        regular.setCompactViewController(compact.viewController)

        model.$selectedSection
            .sink { section in
                let context: UIEntity
                switch section {
                case .home:
                    context = UIEntity.home.screen
                case .saves:
                    context = UIEntity.saves.screen
                case .account:
                    context = UIEntity.account.screen
                }

                let impression = ImpressionEvent(component: .screen, requirement: .instant)
                tracker.track(event: impression, [context])
            }
            .store(in: &subscriptions)
    }

    func showInitialView() {
        regular.showInitialView()
    }
}
