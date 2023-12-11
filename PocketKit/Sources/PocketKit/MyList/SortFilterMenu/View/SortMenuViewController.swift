// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Lottie
import Combine
import Textile
import SharedPocketKit

class SortMenuViewController: UIViewController {
    private let tableView = UITableView()
    let viewModel: SortMenuViewModel
    private var subscriptions: [AnyCancellable] = []

    private lazy var tableViewDataSource: UITableViewDiffableDataSource<SortSection, SortOption> = {
        let dataSource = UITableViewDiffableDataSource<SortSection, SortOption>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
            let cell: SortMenuViewCell = tableView.dequeueCell(for: indexPath)
            cell.model = self?.viewModel.cellViewModel(for: itemIdentifier)
            return cell
        }
        return dataSource
    }()

    init(viewModel: SortMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        configureTableView()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = tableView
    }
}

// MARK: View Setup & Configuration
extension SortMenuViewController {
    func configureTableView() {
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 28.0
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.accessibilityIdentifier = "sort-menu"
        tableView.register(cellClass: SortMenuViewCell.self)
        tableView.register(headerFooterView: SortMenuHeaderView.self)
    }

    func setupBindings() {
        viewModel.$snapshot.sink { [weak self] snapshot in
            self?.tableViewDataSource.apply(snapshot)
        }.store(in: &subscriptions)
    }
}

// MARK: TableView Delegates
extension SortMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: SortMenuHeaderView = tableView.dequeueReusableHeaderFooterView()
        headerView.setHeader(title: SortSection.allCases[section].localized)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedRow = tableViewDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.select(row: selectedRow)
    }
}
