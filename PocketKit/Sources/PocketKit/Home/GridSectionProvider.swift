// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import Sync
import UIKit

/// Configures the section layout for items in slate detail view and native collections
@MainActor
final class GridSectionLayoutProvider {
    private enum Constants {
        static let itemPadding = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        static let interItemSpacing: CGFloat = 16
        /// Minimum width length to qualify for a full (3 column) grid layout on iPad
        static let minWidthBoundaryForFullColumnLayout: CGFloat = 800
    }

    /// Top level function to determine the section layout for the slate detail view or native collections view
    /// - Parameters:
    ///   - viewModels: list of items to display
    ///   - environment: environment to retrieve view details
    ///   - view: view that we want to provide a layout for
    /// - Returns: compact (1 column view) or wide grid layout ( 2 or 3 column view)
    func gridSection(for viewModels: [ItemCellViewModel], with environment: NSCollectionLayoutEnvironment, and view: UIView) -> NSCollectionLayoutSection {
        let width = environment.container.effectiveContentSize.width
        let margin = environment.traitCollection.shouldUseWideLayout() ? Margins.iPadNormal.rawValue : Margins.normal.rawValue

        if environment.traitCollection.shouldUseWideLayout() {
            return sectionForWideLayout(with: viewModels, width: width, margin: margin, view: view)
        } else {
            return sectionForCompact(with: viewModels, width: width, margin: margin)
        }
    }

    /// Determines the section layout on iPad mode with regular horizontal size class (including split view). Number of columns for the grid layout depends on device orientation and the view's width length.
    /// - Parameters:
    ///   - viewModels: list of items to display
    ///   - width: width that the section occupies
    ///   - margin: padding adding to the side of the section
    /// - Returns: section layout for iPad view and regular horizontal size class
    private func sectionForWideLayout(with viewModels: [ItemCellViewModel], width: CGFloat, margin: CGFloat, view: UIView) -> NSCollectionLayoutSection {
        let numberOfColumns = numberOfColumns(with: view)
        let recommendationsHeight = viewModels.compactMap {
            getRecommendationHeight(for: $0, width: width, margin: margin, numberOfColumns: numberOfColumns)
        }
        /// Retrieves max height for each row and returns an array of row heights
        let rowHeights = recommendationsHeight.maxHeightForRow(of: numberOfColumns)
        let components = createComponentsForWideLayout(with: viewModels, numberOfColumns: numberOfColumns, rowHeights: rowHeights)
        return createSectionFromGroup(with: components, and: margin)
    }

    /// Determines the section layout for the slate detail view on iPhone mode (single column layout)
    /// - Parameters:
    ///   - viewModels: list of items to display
    ///   - width: width that the section occupies
    ///   - margin: padding adding to the side of the section
    /// - Returns: section layout for compact (i.e. iPhone mode)
    private func sectionForCompact(with viewModels: [ItemCellViewModel], width: CGFloat, margin: CGFloat) -> NSCollectionLayoutSection {
        let components = createComponentsForCompact(with: viewModels, width: width, margin: margin)
        return createSectionFromGroup(with: components, and: margin)
    }

    /// Determines the number of columns for the layout. If view's width is at least 800 and landscape mode, show 3 col; else 2 column
    /// - Parameter view: view that we want to provide a layout for
    /// - Returns: 3 if the view meets the requirements for a three column layout, otherwise 2
    private func numberOfColumns(with view: UIView) -> Int {
        let hasRequirementForThreeColumnLayout = view.bounds.width >= Constants.minWidthBoundaryForFullColumnLayout && !UIDevice.current.orientation.isPortrait
        return hasRequirementForThreeColumnLayout ? 3 : 2
    }

    /// Create components needed for wide section layout
    /// - Parameters:
    ///   - viewModels: list of recommendations to display to the user
    ///   - width: width that the section occupies
    ///   - margin: margin for the section layout
    /// - Returns: tuple of total height and list of items used to determine section layout
    private func createComponentsForWideLayout(with viewModels: [ItemCellViewModel], numberOfColumns: Int, rowHeights: [CGFloat]) -> (CGFloat, [NSCollectionLayoutGroup]) {
        let numberOfRows = (CGFloat(viewModels.count) / CGFloat(numberOfColumns)).rounded(.up)
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1 / CGFloat(numberOfColumns)),
                heightDimension: .fractionalHeight(1)
            )
        )

        item.contentInsets = Constants.itemPadding

        return (0..<Int(numberOfRows)).reduce((CGFloat(0), [NSCollectionLayoutGroup]())) { result, rowIndex in
            let currentHeight = result.0
            guard let height = rowHeights[safe: rowIndex] else { return result }
            var groups = result.1
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ),
                repeatingSubitem: item,
                count: Int(numberOfColumns)
            )
            group.interItemSpacing = .fixed(Constants.interItemSpacing)
            groups.append(group)
            return (currentHeight + height, groups)
        }
    }

    /// Create components needed for compact section layout
    /// - Parameters:
    ///   - viewModels: list of recommendations to display to the user
    ///   - width: width that the section occupies
    ///   - margin: margin for the section layout
    /// - Returns: tuple of total height and list of items used to determine section layout
    private func createComponentsForCompact(with viewModels: [ItemCellViewModel], width: CGFloat, margin: CGFloat) -> (CGFloat, [NSCollectionLayoutItem]) {
        return viewModels.reduce((CGFloat(0), [NSCollectionLayoutItem]())) { result, viewModel in
            let currentHeight = result.0
            var items = result.1
            let height = getRecommendationHeight(for: viewModel, width: width, margin: margin)
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                )
            )
            item.contentInsets = Constants.itemPadding
            items.append(item)
            return (currentHeight + height, items)
        }
    }

    /// Get a list of heights for each recommendation item
    /// - Parameters:
    ///   - viewModels: list of recommendations
    ///   - width: width that the section occupies
    ///   - margin: padding adding to the side of the section
    ///   - numberOfColumns: number of columns layout should have
    /// - Returns: return a list of heights for all the recommendations
    private func getRecommendationHeight(for viewModel: ItemCellViewModel, width: CGFloat, margin: CGFloat, numberOfColumns: Int = 1) -> CGFloat {
        HomeItemView.fullHeight(viewModel: viewModel, availableWidth: width / CGFloat(numberOfColumns) - (margin * 2)) + margin
    }

    /// Creates section from group layout
    /// - Parameters:
    ///   - components: components that consist of height and list of items for the group
    ///   - margin: margin for the section layout
    /// - Returns: section layout
    private func createSectionFromGroup(with components: (CGFloat, [NSCollectionLayoutItem]), and margin: CGFloat) -> NSCollectionLayoutSection {
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(components.0)
            ),
            subitems: components.1
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: margin,
            bottom: 0,
            trailing: margin
        )
        return section
    }
}

extension Array where Element == CGFloat {
    /// Retrieves a list of heights for each row
    /// - Parameter size: number of items in a row
    /// - Returns: list of heights for each row
    func maxHeightForRow(of size: Int) -> [CGFloat] {
        guard size > 0 else { return [] }
        var maxHeights: [CGFloat] = []

        for index in stride(from: 0, to: count, by: size) {
            let lastChunkIndex = Swift.min(index + size, count)
            let row = self[index..<lastChunkIndex]

            if let maxValue = row.sorted().last {
                maxHeights.append(maxValue)
            }
        }

        return maxHeights
    }
}
