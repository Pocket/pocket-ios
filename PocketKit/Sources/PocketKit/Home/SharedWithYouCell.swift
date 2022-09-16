//
//  SharedWithYouCell.swift
//  
//
//  Created by Daniel Brooks on 8/26/22.
//

import Foundation
import UIKit
import Textile

import SharedWithYou
import Sync

@available(iOS 16.0, *)
class SharedWithYouCell: HomeCarouselItemCell {

    let attributionView = SWAttributionView()

    private let attributionStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        attributionStack.translatesAutoresizingMaskIntoConstraints = false
        attributionView.horizontalAlignment = .trailing
        attributionView.displayContext = .detail

        attributionStack.addArrangedSubview(attributionView)
    }

    /**
    Overrride the original constraints so we can add in our attribution view from iOS
     */
    override internal func activateConstraints() {
        contentView.addSubview(mainContentStack)
        contentView.addSubview(bottomStack)
        contentView.addSubview(attributionStack)
        contentView.layoutMargins = Constants.layoutMargins

        NSLayoutConstraint.activate([
            mainContentStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainContentStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainContentStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            thumbnailView.heightAnchor.constraint(equalToConstant: StyleConstants.thumbnailSize.height).with(priority: .required),
            thumbnailWidthConstraint!,

            bottomStack.leadingAnchor.constraint(equalTo: mainContentStack.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: mainContentStack.trailingAnchor),
            bottomStack.topAnchor.constraint(equalTo: mainContentStack.bottomAnchor),

            attributionStack.topAnchor.constraint(equalTo: bottomStack.bottomAnchor),
            attributionStack.leadingAnchor.constraint(equalTo: bottomStack.leadingAnchor),
            attributionStack.trailingAnchor.constraint(equalTo: bottomStack.trailingAnchor),
            attributionStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).with(priority: .required),

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@available(iOS 16.0, *)
extension SharedWithYouCell {

    /**
      Override to configure shared with you attribution
     */
    func configure(sharedWithYouModel: HomeSharedWithYouCellViewModel) {
        self.attributionView.highlight = nil
        self.configure(model: sharedWithYouModel)

        Services.shared.sharedWithYouMonitor.highlightCenter!.getHighlightFor(sharedWithYouModel.sharedWithYou.url!) { swHighlight, error in
            if error != nil {
                Crashlogger.capture(error: error!)
            }
            self.attributionView.highlight = swHighlight
        }
    }

}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with { paragraph in
        paragraph.with(lineSpacing: 4).with(lineBreakMode: .byTruncatingTail)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
