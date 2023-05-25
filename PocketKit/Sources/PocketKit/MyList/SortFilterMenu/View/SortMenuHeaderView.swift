// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class SortMenuHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SortMenuHeaderView"
    private var sortIconImageView: UIImageView = {
        let sortIconIV = UIImageView(image: UIImage(asset: .sort))
        sortIconIV.translatesAutoresizingMaskIntoConstraints = false
        sortIconIV.contentMode = .scaleAspectFit
        sortIconIV.widthAnchor.constraint(equalToConstant: SortMenuHeaderView.Constants.SortIcon.width).isActive = true
        sortIconIV.heightAnchor.constraint(equalToConstant: SortMenuHeaderView.Constants.SortIcon.height).isActive = true
        return sortIconIV
    }()

    private var sortTitleLabel: UILabel = {
        let sortTitleLbl = UILabel()
        sortTitleLbl.textColor = UIColor(.ui.grey5)
        return sortTitleLbl
    }()

    private var stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = SortMenuHeaderView.Constants.StackViewContainer.spacing
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupHeaderView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupHeaderView() {
        let containerView = UIView()
        containerView.heightAnchor.constraint(equalToConstant: SortMenuHeaderView.Constants.ContainerView.height).isActive = true
        addSubview(containerView)
        setLayoutConstraints(containerView: self, subView: containerView)

        stackViewContainer.addArrangedSubview(sortIconImageView)
        stackViewContainer.addArrangedSubview(sortTitleLabel)
        containerView.addSubview(stackViewContainer)
        let stackViewPadding = SortMenuPadding(left: SortMenuHeaderView.Constants.StackViewContainer.leftPadding)
        setLayoutConstraints(containerView: containerView, subView: stackViewContainer, padding: stackViewPadding)
    }
}

extension SortMenuHeaderView {
    func setHeader(title: String) {
        sortTitleLabel.attributedText = NSAttributedString(string: title, style: .header.sansSerif.h8)
    }

    private func setLayoutConstraints(containerView: UIView, subView: UIView, padding: SortMenuPadding? = nil) {
        let paddingTemp = padding ?? SortMenuPadding()
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.layoutMargins = UIEdgeInsets(top: paddingTemp.top, left: paddingTemp.left, bottom: paddingTemp.bottom, right: paddingTemp.right)
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
            subView.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor),
            subView.bottomAnchor.constraint(equalTo: containerView.layoutMarginsGuide.bottomAnchor),
            subView.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor)
            ])
    }
}

extension SortMenuHeaderView {
    enum Constants {
        enum ContainerView {
            static let height = 51.0
        }
        enum StackViewContainer {
            static let spacing = 21.0
            static let leftPadding = 29.0
        }
        enum SortIcon {
            static let width = 18.0
            static let height = 16.0
        }
    }

    struct SortMenuPadding {
        var top: CGFloat = 0.0
        var left: CGFloat = 0.0
        var bottom: CGFloat = 0.0
        var right: CGFloat = 0.0

        init(top: Double? = nil, left: Double? = nil, bottom: Double? = nil, right: Double? = nil) {
            self.top = CGFloat(top ?? 0.0)
            self.left = CGFloat(left ?? 0.0)
            self.bottom = CGFloat(bottom ?? 0.0)
            self.right = CGFloat(right ?? 0.0)
        }
    }
}
