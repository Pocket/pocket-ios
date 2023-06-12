// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SwiftUI
import Sync
import SharedPocketKit
import Combine
import SafariServices
import Textile
import PKTListen

struct SavesContainerViewControllerSwiftUI: UIViewControllerRepresentable {
    var model: SavesContainerViewModel

    func makeUIViewController(context: Context) -> UINavigationController {
        let v = SavesContainerViewController(
            savesContainerModel: model,
            viewControllers: [
                ItemsListViewController(model: model.savedItemsList),
                ItemsListViewController(model: model.archivedItemsList)
            ]
        )
        let navigationController = UINavigationController(rootViewController: v)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
        navigationController.delegate = v
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

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

class SavesContainerViewController: UIViewController, UISearchBarDelegate {
    var selectedIndex: Int {
        didSet {
            resetTitleView()
            select(child: viewController(at: selectedIndex))
        }
    }

    var isFromSaves: Bool

    private let viewControllers: [SelectableViewController]
    private var searchViewModel: SearchViewModel
    private var model: SavesContainerViewModel

    private var subscriptions: [AnyCancellable] = []
    private var readableSubscriptions: [AnyCancellable] = []

    init(savesContainerModel: SavesContainerViewModel, viewControllers: [SelectableViewController]) {
        selectedIndex = 0
        self.model = savesContainerModel
        self.searchViewModel = savesContainerModel.searchList
        self.viewControllers = viewControllers
        self.isFromSaves = true

        super.init(nibName: nil, bundle: nil)

        viewControllers.forEach { vc in
            addChild(vc)
            vc.didMove(toParent: vc)
        }

        resetTitleView()
        navigationItem.largeTitleDisplayMode = .never
        self.observeModelChanges()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton

        view.accessibilityIdentifier = "saves"
        select(child: viewControllers.first)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }

    @objc
    func addButtonTapped() {
        let addItemView = UIHostingController(rootView: AddSavedItem(model: model.addSavedItemModel))
        present(addItemView, animated: true)
    }

    private func resetTitleView() {
        let selections = viewControllers.map { vc in
            SavesSelection(title: vc.selectionItem.title, image: vc.selectionItem.image) { [weak self] in
                self?.select(child: vc)
            }
        }

        navigationItem.titleView = SavesTitleView(selections: selections)
    }

    private func viewController(at index: Int) -> SelectableViewController? {
        guard index < viewControllers.count else { return nil }
        return viewControllers[index]
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
        searchViewController.view.backgroundColor = UIColor(.ui.white1)
        navigationItem.searchController = UISearchController(searchResultsController: searchViewController)
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.searchController?.searchBar.autocapitalizationType = .none
        navigationItem.searchController?.view.accessibilityIdentifier = "search-view"
        navigationItem.searchController?.searchBar.accessibilityHint = "Search"
        navigationItem.searchController?.searchBar.scopeButtonTitles = searchViewModel.scopeTitles
        navigationItem.searchController?.scopeBarActivation = .onSearchActivation
        navigationItem.preferredSearchBarPlacement = .stacked
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

    var timer: Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            self.searchViewModel.updateSearchResults(with: text)
        })
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
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
        navigationItem.searchController?.isActive = true
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
}

// MARK: Coordination
extension SavesContainerViewController {
    func observeModelChanges() {
        navigationController?.popToRootViewController(animated: false)

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

        model.savedItemsList.$presentedListenViewModel.sink { [weak self] listenViewModel in
            guard let listenViewModel else {
                return
            }
            self?.showListen(listenViewModel: listenViewModel)
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

        model.archivedItemsList.$presentedListenViewModel.sink { [weak self] listenViewModel in
            guard let listenViewModel else {
                return
            }
            self?.showListen(listenViewModel: listenViewModel)
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

            guard let premiumURL = readable?.premiumURL, let url = URL(percentEncoding: premiumURL) else { return }
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
            animated: true
        )
    }

    private func present(alert: PocketAlert?) {
        guard let alert = alert else { return }
        guard let presentedVC = self.presentedViewController else {
            self.present(UIAlertController(alert), animated: true)
            return
        }
        presentedVC.present(UIAlertController(alert), animated: true)
    }

    private func present(viewModel: PocketAddTagsViewModel?) {
        guard true, let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        self.present(hostingController, animated: true)
    }

    private func present(tagsFilterViewModel: TagsFilterViewModel?) {
        guard true, let tagsFilterViewModel = tagsFilterViewModel else { return }
        let hostingController = UIHostingController(rootView: TagsFilterView(viewModel: tagsFilterViewModel).environment(\.managedObjectContext, Services.shared.source.viewContext))
        hostingController.configurePocketDefaultDetents()
        self.present(hostingController, animated: true)
    }

    private func present(activity: PocketActivity?) {
        guard true, let activity = activity else { return }

        let activityVC = ShareSheetController(activity: activity, completion: { [weak self] _, _, _, _ in
                              self?.model.clearSharedActivity()
                          })
         activityVC.modalPresentationStyle = .formSheet
        self.present(activityVC, animated: true)
    }

    private func present(url: URL?) {
        guard true, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard true, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) { [weak self] in
            self?.model.clearIsPresentingReaderSettings()
        }
        readerSettingsVC.configurePocketDefaultDetents()
        self.present(readerSettingsVC, animated: true)
    }

    func presentSortMenu(presentedSortFilterViewModel: SortMenuViewModel?) {
        guard true else {
            return
        }

        guard let sortFilterVM = presentedSortFilterViewModel else {
            if navigationController?.presentedViewController is SortMenuViewController {
                navigationController?.dismiss(animated: true)
            }
            return
        }

        let viewController = SortMenuViewController(viewModel: sortFilterVM)
        viewController.configurePocketDefaultDetents()
        navigationController?.present(viewController, animated: true)
    }

    private func popToPreviousScreen(navigationController: UINavigationController?) {
        guard let navController = navigationController else {
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

extension SavesContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard viewController === self else {
            return
        }

        model.clearSelectedItem()

        // By default, when pushing the reader, switching to landscape, and popping,
        // the list will remain in landscape despite only supporting portrait.
        // We have to programatically force the device orientation back to portrait,
        // if the view controller we want to show _only_ supports portrait
        // (e.g when popping from the reader).
        if viewController.supportedInterfaceOrientations == .portrait, UIDevice.current.orientation.isLandscape {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard navigationController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return navigationController.visibleViewController?.supportedInterfaceOrientations ?? .portrait
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

extension SavesContainerViewController {
    private func showListen(listenViewModel: ListenViewModel) {
        let appConfig = PKTListenAppConfiguration(source: listenViewModel)
        let listen =  PKTListenContainerViewController(configuration: appConfig)
        listen.title = listenViewModel.title
        self.present(listen, animated: true)
    }
}
