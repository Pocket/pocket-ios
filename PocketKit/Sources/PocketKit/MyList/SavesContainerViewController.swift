import UIKit
import SwiftUI
import Sync
import SharedPocketKit
import Combine
import SafariServices
import Textile

struct SelectionItem {
    let title: String
    let image: UIImage
    let selectedView: SelectedView
}

public enum SelectedView {
    case saves
    case archive
}

protocol SelectableViewController: UIViewController {
    var selectionItem: SelectionItem { get }

    func didBecomeSelected(by parent: SavesContainerViewController)
}

struct SavesContainerViewControllerSwiftUI: UIViewControllerRepresentable {
    var model: SavesContainerViewModel

    func makeUIViewController(context: Context) -> SavesContainerViewController {
        let v = SavesContainerViewController(model: model)
        return v
    }

    func updateUIViewController(_ uiViewController: SavesContainerViewController, context: Context) {
    }
}

class SavesContainerViewController: UIViewController, UISearchBarDelegate {
    var selectedIndex: Int {
        didSet {
            select(child: viewController(at: selectedIndex))
        }
    }

    var isFromSaves: Bool

    private let viewControllers: [SelectableViewController]
    private let savesController: SelectableViewController
    private let archiveController: SelectableViewController

    private var searchViewModel: SearchViewModel
    private var subscriptions: [AnyCancellable] = []
    private var readableSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false
    private let model: SavesContainerViewModel

    convenience init(model: SavesContainerViewModel) {
        self.init(
            model: model,
            savesController: ItemsListViewController(model: model.savedItemsList),
            archiveController: ItemsListViewController(model: model.archivedItemsList)
        )
    }

    init(model: SavesContainerViewModel, savesController: SelectableViewController, archiveController: SelectableViewController) {
        selectedIndex = 0
        self.model = model
        self.searchViewModel = self.model.searchList
        self.archiveController = archiveController
        self.savesController = savesController
        self.viewControllers = [savesController, archiveController]
        self.isFromSaves = true

        super.init(nibName: nil, bundle: nil)

        viewControllers.forEach { vc in
            addChild(vc)
            vc.didMove(toParent: vc)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "saves"
        self.observeModelChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        select(child: savesController)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }

    private func viewController(at index: Int) -> SelectableViewController? {
        guard index < viewControllers.count else { return nil }
        return viewControllers[index]
    }

    private func select(selectionItem: SelectionItem) {
        switch selectionItem.selectedView {
        case .saves:
            select(child: savesController)
        case .archive:
            select(child: archiveController)
        }
    }

    private func select(child: SelectableViewController?) {
        guard let child = child else {
            return
        }

        navigationItem.backButtonTitle = child.selectionItem.title
        viewControllers
            .compactMap(\.viewIfLoaded)
            .forEach { $0.removeFromSuperview() }
        view.addSubview(child.view)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        child.didBecomeSelected(by: self)

        if child.selectionItem.selectedView == SelectedView.saves {
            isFromSaves = true
        } else {
            isFromSaves = false
        }
        setupSearch()
    }

    // MARK: Search
    private func setupSearch() {
        let searchViewController = UIHostingController(rootView: SearchView(viewModel: searchViewModel))
        navigationItem.searchController = UISearchController(searchResultsController: searchViewController)
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.searchController?.searchBar.autocapitalizationType = .none
        navigationItem.searchController?.view.accessibilityIdentifier = "search-view"
        navigationItem.searchController?.searchBar.accessibilityHint = "Search"
        navigationItem.searchController?.searchBar.scopeButtonTitles = searchViewModel.scopeTitles
        if #available(iOS 16.0, *) {
            navigationItem.searchController?.scopeBarActivation = .onSearchActivation
        } else {
            navigationItem.searchController?.automaticallyShowsScopeBar = true
        }
        navigationItem.searchController?.showsSearchResultsController = true

        searchViewModel.$searchText.dropFirst().sink { searchText in
            self.updateSearchBar(searchText: searchText)
        }.store(in: &subscriptions)
    }

    func updateSearchBar(searchText: String) {
        let searchBar = navigationItem.searchController?.searchBar
        searchBar?.text = searchText
        searchBar?.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let titles = searchBar.scopeButtonTitles else { return }
        searchBar.returnKeyType = .search
        let searchScope = SearchScope(rawValue: titles[selectedScope]) ?? .saves
        searchViewModel.trackSwitchScope(with: searchScope)
        searchViewModel.updateScope(with: searchScope, searchTerm: searchBar.text)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        searchViewModel.updateSearchResults(with: text)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard navigationItem.searchController?.isActive == false else { return }
        updateSearchScope()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchViewModel.clear()
        searchBar.text = nil
    }

    func updateSearchScope() {
        let scope: SearchScope = isFromSaves ? .saves : .archive
        searchViewModel.updateScope(with: scope)

        if isFromSaves {
            navigationItem.searchController?.searchBar.selectedScopeButtonIndex = 0
        } else {
            navigationItem.searchController?.searchBar.selectedScopeButtonIndex = 1
        }
    }
}

extension SavesContainerViewController {
    func observeModelChanges() {
        isResetting = true
        navigationController?.delegate = self

        // navigationController?.popToRootViewController(animated: false)

        model.$selection.sink { [weak self] selection in
            switch selection {
            case .saves:
                self?.selectedIndex = 0
            case .archive:
                self?.selectedIndex = 1
            }
        }.store(in: &subscriptions)

        // Saves navigation
        model.savedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSearch.sink { [weak self] alert in
            self?.updateSearchScope()
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedTagsFilter.sink { [weak self] tagsFilterViewModel in
            self?.present(tagsFilterViewModel: tagsFilterViewModel)
        }.store(in: &subscriptions)

        model.savedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.savedItemsList.$selectedItem.sink { [weak self] selectedSavedItem in
            guard let selectedSavedItem = selectedSavedItem else { return }
            self?.navigate(selectedItem: selectedSavedItem)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        // Archive navigation
        model.archivedItemsList.$selectedItem.sink { [weak self] selectedArchivedItem in
            guard let selectedArchivedItem = selectedArchivedItem else { return }
            self?.navigate(selectedItem: selectedArchivedItem)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedSearch.sink { [weak self] alert in
            self?.updateSearchScope()
        }.store(in: &subscriptions)

        model.archivedItemsList.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedSortFilterViewModel.receive(on: DispatchQueue.main).sink { [weak self] presentedSortFilterViewModel in
            self?.presentSortMenu(presentedSortFilterViewModel: presentedSortFilterViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedTagsFilter.sink { [weak self] tagsFilterViewModel in
            self?.present(tagsFilterViewModel: tagsFilterViewModel)
        }.store(in: &subscriptions)

        // Search navigation
        model.searchList.$selectedItem.sink { [weak self] selectedArchivedItem in
            guard let selectedArchivedItem = selectedArchivedItem else { return }
            self?.navigate(selectedItem: selectedArchivedItem)
        }.store(in: &subscriptions)

        isResetting = false
    }

    private func navigate(selectedItem: SelectedItem) {
        switch selectedItem {
        case .readable(let readable):
            self.push(savedItem: readable)
        case .webView(let readable):
            readable?.$presentedAlert.sink { [weak self] alert in
                self?.present(alert: alert)
            }.store(in: &readableSubscriptions)

            readable?.events.sink { [weak self] event in
                switch event {
                case .contentUpdated:
                    break
                case .archive, .delete:
                    self?.popToPreviousScreen(navigationController: self?.navigationController)
                }
            }.store(in: &readableSubscriptions)

            guard let url = readable?.url else { return }
            self.present(url: url)
        }
    }

    private func push(savedItem: SavedItemViewModel?) {
        guard let readable = savedItem else {
            readableSubscriptions = []
            return
        }

        readable.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readableSubscriptions)

        readable.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &readableSubscriptions)

        readable.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readableSubscriptions)

        readable.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: readable)
        }.store(in: &readableSubscriptions)

        readable.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(viewModel: addTagsViewModel)
        }.store(in: &readableSubscriptions)

        readable.events.sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen(navigationController: self?.navigationController)
            }
        }.store(in: &readableSubscriptions)

        navigationController?.pushViewController(
            ReadableHostViewController(readableViewModel: readable),
            animated: !isResetting
        )
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        guard let presentedVC = self.navigationController?.presentedViewController else {
            self.navigationController?.present(UIAlertController(alert), animated: !isResetting)
            return
        }
        presentedVC.present(UIAlertController(alert), animated: !isResetting)
    }

    private func present(viewModel: PocketAddTagsViewModel?) {
        guard !isResetting, let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        self.navigationController?.present(hostingController, animated: !isResetting)
    }

    private func present(tagsFilterViewModel: TagsFilterViewModel?) {
        guard !isResetting, let tagsFilterViewModel = tagsFilterViewModel else { return }
        let hostingController = UIHostingController(rootView: TagsFilterView(viewModel: tagsFilterViewModel))
        hostingController.configurePocketDefaultDetents()
        self.present(hostingController, animated: !isResetting)
    }

    private func present(activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.clearSharedActivity()
        }

        self.navigationController?.present(activityVC, animated: !isResetting)
    }

    private func present(url: URL?) {
        guard !isResetting, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .fullScreen
        self.present(safariVC, animated: !isResetting)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard !isResetting, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) { [weak self] in
            self?.model.clearIsPresentingReaderSettings()
        }
        readerSettingsVC.configurePocketDefaultDetents()
        self.navigationController?.present(readerSettingsVC, animated: !isResetting)
    }

    func presentSortMenu(presentedSortFilterViewModel: SortMenuViewModel?) {
        guard !isResetting else {
            return
        }

        guard let sortFilterVM = presentedSortFilterViewModel else {
            if self.navigationController?.presentedViewController is SortMenuViewController {
                self.navigationController?.dismiss(animated: true)
            }
            return
        }

        let viewController = SortMenuViewController(viewModel: sortFilterVM)
        viewController.configurePocketDefaultDetents()
        self.navigationController?.present(viewController, animated: true)
    }

    private func popToPreviousScreen(navigationController: UINavigationController?) {
        guard let navController = self.parent?.navigationController else {
            return
        }

        if let presentedVC = navController.presentedViewController {
            presentedVC.dismiss(animated: true) {
                navController.popToRootViewController(animated: true)
            }
        } else {
            navController.popViewController(animated: true)
        }
    }
}

extension SavesContainerViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return model.activityItemsForSelectedItem(url: URL)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}

extension SavesContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // By default, when pushing the reader, switching to landscape, and popping,
        // the list will remain in landscape despite only supporting portrait.
        // We have to programatically force the device orientation back to portrait,
        // if the view controller we want to show _only_ supports portrait
        // (e.g when popping from the reader).
        if viewController.supportedInterfaceOrientations == .portrait, UIDevice.current.orientation.isLandscape {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }

        if viewController === self {
            model.clearSelectedItem()
        }
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard navigationController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return navigationController.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
}
