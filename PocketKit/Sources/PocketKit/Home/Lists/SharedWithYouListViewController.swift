// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Analytics
import Combine
import Lottie
import Textile
import Localization

class SharedWithYouListViewController: UIViewController {
    private lazy var layoutConfiguration = UICollectionViewCompositionalLayout { [weak self] index, env in
        return self?.section(for: index, environment: env)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<SharedWithYouListViewModel.Section, SharedWithYouListViewModel.Cell> = {
        UICollectionViewDiffableDataSource<SharedWithYouListViewModel.Section, SharedWithYouListViewModel.Cell>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, viewModelCell) -> UICollectionViewCell? in
            return self?.cell(for: viewModelCell, at: indexPath)
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutConfiguration)
        return collectionView
    }()

    private lazy var overscrollView: EndOfFeedAnimationView = {
        let view = EndOfFeedAnimationView(frame: .zero)
        view.accessibilityIdentifier = "slate-detail-overscroll"
        view.alpha = 0
        view.attributedText = NSAttributedString(
            string: Localization.youReAllCaughtUpCheckBackLaterForMore,
            style: .overscroll
        )
        return view
    }()

    private let sectionProvider: GridSectionLayoutProvider
    private var overscrollTopConstraint: NSLayoutConstraint?
    private var overscrollOffset = 0

    private var subscriptions: [AnyCancellable] = []

    private let viewModel: SharedWithYouListViewModel

    init(
        viewModel: SharedWithYouListViewModel
    ) {
        self.viewModel = viewModel

        sectionProvider = GridSectionLayoutProvider()

        super.init(nibName: nil, bundle: nil)

        view.accessibilityIdentifier = "slate-detail"
        navigationItem.title = Localization.SharedWithYou.title
        hidesBottomBarWhenPushed = true

        let largeTitleTwoLineMode = "_largeTitleTwoLineMode"
        if class_getProperty(UINavigationItem.self, largeTitleTwoLineMode) != nil {
            navigationItem.setValue(true, forKey: largeTitleTwoLineMode)
        }

        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            let divider: DividerView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            return divider
        }

        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        collectionView.register(cellClass: LoadingCell.self)
        collectionView.register(cellClass: SharedWithYouItemCell.self)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: "divider")

        collectionView.publisher(for: \.contentSize, options: [.new]).sink { [weak self] contentSize in
            self?.setupOverflowView(contentSize: contentSize)
        }.store(in: &subscriptions)

        collectionView.publisher(for: \.contentOffset, options: [.new]).sink { [weak self] contentOffset in
            self?.updateOverflowView(contentOffset: contentOffset)
        }.store(in: &subscriptions)

        viewModel.$snapshot.receive(on: DispatchQueue.main).sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot)
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        overscrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overscrollView)
        overscrollTopConstraint = overscrollView.topAnchor.constraint(equalTo: collectionView.bottomAnchor)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overscrollTopConstraint!,
            overscrollView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            overscrollView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            overscrollView.heightAnchor.constraint(equalToConstant: 96)
        ])

        viewModel.fetch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.trackSlateDetailViewed()
    }
}

private extension SharedWithYouListViewController {
    func setupOverflowView(contentSize: CGSize) {
        let shouldHide = contentSize.height <= collectionView.frame.height
        overscrollView.isHidden = shouldHide
    }

    func updateOverflowView(contentOffset: CGPoint) {
        guard collectionView.contentSize.height > collectionView.frame.height else {
            return
        }

        let visibleHeight = round(
            collectionView.frame.height
            - collectionView.adjustedContentInset.top
            - collectionView.adjustedContentInset.bottom
        )
        let yOffset = round(contentOffset.y + collectionView.adjustedContentInset.top)
        let overscroll = max(-round(collectionView.contentSize.height - yOffset - visibleHeight), 0)

        if overscroll > 0 {
            let constant = overscroll + collectionView.adjustedContentInset.bottom
            overscrollTopConstraint?.constant = -constant
            overscrollView.alpha = min(overscroll / 96, 1)

            if !overscrollView.didFinishPreviousAnimation {
                overscrollView.isAnimating = true
            }
        }

        if overscroll == 0 {
            if overscrollView.didFinishPreviousAnimation {
                overscrollView.isAnimating = false
            }
        }
    }

    func section(for index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let section = self.dataSource.sectionIdentifier(for: index)
        switch section {
        case .loading:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.8)
                ),
                subitems: [item]
            )

            return NSCollectionLayoutSection(group: group)
        case .list(let list):
            let viewModels = list.compactMap { viewModel.cellViewModel(for: $0.objectID) }

            return sectionProvider.gridSection(for: viewModels, with: environment, and: view)
        default:
            return .empty()
        }
    }

    func cell(
        for viewModelCell: SharedWithYouListViewModel.Cell,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch viewModelCell {
        case .loading:
            let cell: LoadingCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case .item(let objectID):
            let cell: SharedWithYouItemCell = collectionView.dequeueCell(for: indexPath)

            guard let viewModel = self.viewModel.cellViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        }
    }
}

extension SharedWithYouListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        viewModel.willDisplay(cell, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        viewModel.select(cell: cell, at: indexPath)
    }
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
