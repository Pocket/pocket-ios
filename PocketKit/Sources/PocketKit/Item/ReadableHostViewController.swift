// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Combine
import Analytics
import Sync
import Textile

class ReadableHostViewController: UIViewController {
    private let moreButtonItem: UIBarButtonItem
    private var subscriptions: [AnyCancellable] = []
    private var readableViewModel: ReadableViewModel

    private lazy var getArchiveButton: UIBarButtonItem = {
        let archiveNavButton = UIBarButtonItem(
            image: UIImage(asset: .archive),
            style: .plain,
            target: self,
            action: #selector(archive)
        )

        archiveNavButton.accessibilityIdentifier = "archiveNavButton"
        return archiveNavButton
    }()

    private lazy var getMoveFromArchiveToSavesButton: UIBarButtonItem = {
        let moveFromArchiveToSavesNavButton = UIBarButtonItem(
            image: UIImage(asset: .save),
            style: .plain,
            target: self,
            action: #selector(moveFromArchiveToSaves)
        )

        moveFromArchiveToSavesNavButton.accessibilityIdentifier = "moveFromArchiveToSavesNavButton"
        return moveFromArchiveToSavesNavButton
    }()

    init(readableViewModel: ReadableViewModel) {
        self.readableViewModel = readableViewModel
        self.moreButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: nil
        )

        super.init(nibName: nil, bundle: nil)

        title = nil
        navigationItem.largeTitleDisplayMode = .never
        hidesBottomBarWhenPushed = true

        let listenButtonItem = UIBarButtonItem(
            image: UIImage(asset: .listen),
            style: .plain,
            target: self,
            action: #selector(listen)
        )
        listenButtonItem.isEnabled = readableViewModel.isListenSupported

        navigationItem.rightBarButtonItems = [
            moreButtonItem,
            UIBarButtonItem(
                image: UIImage(systemName: "safari"),
                style: .plain,
                target: self,
                action: #selector(showWebView)
            ),
            readableViewModel.isArchived ? getMoveFromArchiveToSavesButton : getArchiveButton,
            listenButtonItem
        ]

        readableViewModel.actions.receive(on: DispatchQueue.main).sink { [weak self] actions in
            self?.buildOverflowMenu(from: actions)
        }.store(in: &subscriptions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This view is hosted in SwitUI and it seems that hidesBottomBarWhenPushed is not resepected,
        // but manually hiding the tab bar does
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lockOrientation(.allButUpsideDown)
    }

    override func viewDidDisappear(_ animated: Bool) {
        lockOrientation(.portrait)
        super.viewDidDisappear(animated)
    }

    override func loadView() {
        view = UIView()

        let readableViewController = ReadableViewController(
            readable: readableViewModel,
            readerSettings: readableViewModel.readerSettings
        )
        readableViewController.delegate = readableViewModel

        readableViewController.willMove(toParent: self)
        addChild(readableViewController)
        view.addSubview(readableViewController.view)
        readableViewController.didMove(toParent: self)

        readableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            readableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            readableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            readableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            readableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func buildOverflowMenu(from actions: [ItemAction]) {
        moreButtonItem.menu = UIMenu(
            image: nil,
            identifier: nil,
            options: [],
            children: [
                UIDeferredMenuElement.uncached { [weak self] completion in
                    self?.readableViewModel.trackOverflow()
                    completion(actions.compactMap(UIAction.init))
                }
            ]
        )
    }

    required init?(coder: NSCoder) {
        fatalError("\(Self.self) cannot be instantiated from a xib/storyboard")
    }

    @objc
    private func showWebView() {
        readableViewModel.showWebReader()
    }

    @objc
    private func archive() {
        readableViewModel.archive()
    }

    @objc
    private func moveFromArchiveToSaves() {
        readableViewModel.moveFromArchiveToSaves { [weak self] success in
            if success,
               let items = self?.navigationItem.rightBarButtonItems,
               let getMoveFromArchiveToSavesButton = self?.getMoveFromArchiveToSavesButton,
               let index = items.firstIndex(of: getMoveFromArchiveToSavesButton),
               let archiveButton = self?.getArchiveButton {
                self?.navigationItem.rightBarButtonItems?[index] = archiveButton
            }
        }
    }

    @objc
    private func listen() {
        readableViewModel.listen()
    }

    var popoverAnchor: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?[0]
    }
}
