import UIKit
import Analytics
import Sync
import Combine
import BackgroundTasks


class MainCoordinator {
    var viewController: UIViewController {
        regular.viewController
    }

    private let compact: CompactMainCoordinator
    private let regular: RegularMainCoordinator
    
    private var subscriptions: Set<AnyCancellable> = []

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
        
        model.$selectedSection
            .sink { section in
                let context: UIContext
                switch section {
                case .home:
                    context = UIContext.home.screen
                case .myList:
                    context = UIContext.myList.screen
                case .settings:
                    context = UIContext.settings.screen
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
