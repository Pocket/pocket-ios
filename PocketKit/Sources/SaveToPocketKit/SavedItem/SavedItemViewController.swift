// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Combine
import Textile
import SwiftUI
import SharedPocketKit

class SavedItemViewController: UIViewController {
    private let imageView = UIImageView(image: UIImage(asset: .logo))
    private let infoView = InfoView()
    private let dismissLabel = UILabel()
    private let viewModel: SavedItemViewModel

    private var infoViewModelSubscription: AnyCancellable?
    private var subscriptions: [AnyCancellable] = []

    private lazy var addTagsButton: UIButton = {
        var configuration: UIButton.Configuration = .filled()
        configuration.background.backgroundColor = UIColor(.ui.teal2).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        configuration.background.cornerRadius = 13
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0)
        configuration.attributedTitle = AttributedString(viewModel.tagsActionAttributedText)

        let button = UIButton(
            configuration: configuration,
            primaryAction: nil
        )

        button.accessibilityIdentifier = "add-tags-button"
        return button
    }()

    private lazy var openInPocketButton: UIButton = {
        var configuration: UIButton.Configuration = .filled()
        configuration.background.backgroundColor = UIColor(.ui.teal2).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        configuration.background.cornerRadius = 13
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 0, bottom: 13, trailing: 0)
        configuration.attributedTitle = AttributedString(viewModel.openInPocket)

        let button = UIButton(
            configuration: configuration,
            primaryAction: nil
        )

        button.accessibilityIdentifier = "open-in-pocket-button"
        return button
    }()

    init(viewModel: SavedItemViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        infoViewModelSubscription = viewModel.$infoViewModel.receive(on: DispatchQueue.main).sink { [weak self] infoViewModel in
            self?.infoView.model = infoViewModel
        }

        viewModel.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(addTagsViewModel)
        }.store(in: &subscriptions)

        addTagsButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.cancelDismissTimer()
            self?.viewModel.showAddTagsView(from: self?.extensionContext)
        }, for: .primaryActionTriggered)

        openInPocketButton.addAction(UIAction { [weak self] _ in
            Task { @MainActor in
                await self?.viewModel.open(from: self?.extensionContext)
            }
        }, for: .primaryActionTriggered)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(.ui.white1)

        view.addSubview(imageView)
        view.addSubview(infoView)
        view.addSubview(dismissLabel)
        view.addSubview(addTagsButton)
        view.addSubview(openInPocketButton)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        dismissLabel.translatesAutoresizingMaskIntoConstraints = false
        addTagsButton.translatesAutoresizingMaskIntoConstraints = false
        openInPocketButton.translatesAutoresizingMaskIntoConstraints = false

        let capsuleTopConstraint = NSLayoutConstraint(
            item: infoView,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 0.35,
            constant: 0
        )

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),

            capsuleTopConstraint,
            addTagsButton.bottomAnchor.constraint(equalTo: dismissLabel.topAnchor, constant: -16),
            addTagsButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addTagsButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            capsuleTopConstraint,
            openInPocketButton.bottomAnchor.constraint(equalTo: addTagsButton.topAnchor, constant: -16),
            openInPocketButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            openInPocketButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            dismissLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        if traitCollection.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                infoView.widthAnchor.constraint(equalToConstant: 379)
            ])
        } else {
            NSLayoutConstraint.activate([
                infoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                infoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
            ])
        }

        dismissLabel.attributedText = viewModel.dismissAttributedText

        let tap = UITapGestureRecognizer(target: self, action: #selector(finish))
        view.addGestureRecognizer(tap)

        Task {
            await viewModel.save(from: extensionContext)
        }
    }

    @objc
    private func finish() {
        viewModel.finish(context: extensionContext)
    }

    func present(_ viewModel: SaveToAddTagsViewModel?) {
        guard let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        self.present(hostingController, animated: true)
    }
}
