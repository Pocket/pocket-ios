//
//  File.swift
//  
//
//  Created by Conor Masterson on 2023-05-29.
//

import Foundation
import UIKit

class ItemListCollectionView: UICollectionView {
    private var regularConstraints: [NSLayoutConstraint] = []
    private var compactConstraints: [NSLayoutConstraint] = []

    func loadConstraints() {
        regularConstraints = initRegularConstraints()
        compactConstraints = initCompactConstraints()
    }

    func applyConstraints(for sizeClass: UIUserInterfaceSizeClass) {
        if sizeClass == .regular {
            compactConstraints.forEach {
                $0.isActive = false
            }
            regularConstraints.forEach {
                $0.isActive = true
            }
        } else {
            regularConstraints.forEach {
                $0.isActive = false
            }
            compactConstraints.forEach {
                $0.isActive = true
            }
        }

        self.setNeedsUpdateConstraints()
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func clearConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
    }

    private func initRegularConstraints() -> [NSLayoutConstraint] {
        guard let superview else { return [] }

        return [self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                self.topAnchor.constraint(equalTo: superview.topAnchor),
                self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
                self.widthAnchor.constraint(equalToConstant: 500)]
    }

    private func initCompactConstraints() -> [NSLayoutConstraint] {
        guard let superview else { return [] }

        return [self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                self.topAnchor.constraint(equalTo: superview.topAnchor),
                self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)]
    }
}
