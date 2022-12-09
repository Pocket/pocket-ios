import UIKit
import SwiftUI
import Sync
import SharedPocketKit

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

    init(searchViewModel: SearchViewModel, viewControllers: [SelectableViewController]) {
        selectedIndex = 0
        self.searchViewModel = searchViewModel
        self.viewControllers = viewControllers
        self.isFromSaves = true

        super.init(nibName: nil, bundle: nil)

        viewControllers.forEach { vc in
            addChild(vc)
            vc.didMove(toParent: vc)
        }

        resetTitleView()
        navigationItem.largeTitleDisplayMode = .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let titles = searchBar.scopeButtonTitles else { return }
        searchViewModel.updateScope(with: SearchScope(rawValue: titles[selectedScope]) ?? .saves)
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
