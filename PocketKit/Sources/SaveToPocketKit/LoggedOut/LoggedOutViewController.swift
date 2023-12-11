// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Combine

class LoggedOutViewController: UIViewController {
    private let imageView = UIImageView(image: UIImage(asset: .logo))

    private let infoView = InfoView()

    private let dismissLabel = UILabel()

    private let viewModel: LoggedOutViewModel

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: LoggedOutViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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

        imageView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        dismissLabel.translatesAutoresizingMaskIntoConstraints = false

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

        infoView.model = viewModel.infoViewModel
        dismissLabel.attributedText = viewModel.dismissAttributedText

        let tap = UITapGestureRecognizer(target: self, action: #selector(finish))
        view.addGestureRecognizer(tap)

        viewModel.$actionButtonConfiguration.prefix(2).sink { [weak self] configuration in
            if let configuration = configuration {
                self?.createActionButton(configuration: configuration)
            }
        }.store(in: &subscriptions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.viewWillAppear(context: extensionContext, origin: self)
    }
}

private extension LoggedOutViewController {
    @objc
    private func finish() {
        viewModel.finish(context: extensionContext)
    }

    private func logIn() {
        viewModel.logIn(from: extensionContext, origin: self)
    }

    private func createActionButton(configuration: UIButton.Configuration) {
        let actionButton = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in
                self?.logIn()
            }
        )
        actionButton.accessibilityIdentifier = "log-in"

        view.addSubview(actionButton)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: dismissLabel.topAnchor, constant: -16),
            actionButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            actionButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}
