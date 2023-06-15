// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable multiline_arguments_brackets
import Foundation
import Localization
import SwiftUI
import Textile
import WidgetKit

/// Header for an item widget
struct ItemsHeader: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    let title: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .style(.widgetHeader)
            Spacer()
            Image(asset: .saved)
                .resizable()
                .foregroundColor(Color(.ui.coral2))
                .frame(width: ItemsView.Size.logoSize.width,
                       height: ItemsView.Size.logoSize.height,
                       alignment: .center)
        }
    }
}

/// Item widgets - list view
struct ItemsView: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    let items: [ItemRowContent]

    var body: some View {
        VStack(alignment: .leading) {
            ItemsHeader(title: Localization.Widgets.RecentSaves.title)
            Spacer()
            ForEach(items) { entry in
                ItemRow(title: entry.content.title.isEmpty ? entry.content.url : entry.content.title,
                        domain: entry.content.bestDomain,
                        readingTime: entry.content.readingTime,
                        image: entry.image)
                .padding(.top, Size.cellPadding(for: widgetFamily))
                .padding(.bottom, Size.cellPadding(for: widgetFamily))
            }
        }
    }
}

/// Recent Saves widget - saved item view
struct ItemRow: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    let title: String
    let domain: String
    let readingTime: String?
    let image: Image?

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .style(.header.sansSerif.w8)
                    .lineLimit(ItemsView.Size.lineLimit(for: widgetFamily))
                    .fixedSize(horizontal: false, vertical: true)
                if let readingTime {
                    Text(domain + " - " + readingTime)
                        .style(.domain)
                } else {
                    Text(domain)
                        .style(.domain)
                }
            }
            Spacer()
            if let image {
                ItemThumbnail(image: image)
            }
        }
    }
}

/// Recent Saves widget - saved item thumbnail
struct ItemThumbnail: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    let image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                width: ItemsView.Size.thumbnailSize(for: widgetFamily).width
            )
            .cornerRadius(8)
    }
}

private extension Style {
    static let domain: Style = .header.sansSerif.p6.with(color: .ui.grey8)
    static let widgetHeader: Style = .header.sansSerif.h8.with(color: .ui.coral2)
}

// MARK: formatting
private extension ItemsView {
    enum Size {
        static func cellPadding(for family: WidgetFamily) -> CGFloat {
            switch family {
            case .systemMedium:
                return 2
            case .systemLarge:
                return 4
            default:
                return 0
            }
        }

        static func bottomHeaderPadding(for family: WidgetFamily) -> CGFloat {
            switch family {
            case .systemLarge:
                return 4
            default:
                return 0
            }
        }

        static let logoSize: CGSize = CGSize(width: 18, height: 16)

        static func lineLimit(for family: WidgetFamily) -> Int {
            switch family {
            case .systemLarge:
                return 3
            case .systemMedium:
                return 2
            default:
                return 0
            }
        }

        static func thumbnailSize( for family: WidgetFamily) -> CGSize {
            switch family {
            case .systemLarge:
                return RecentSavesProvider.defaultThumbnailSize
            case .systemMedium:
                return CGSize(width: RecentSavesProvider.defaultThumbnailSize.width * 0.8,
                              height: RecentSavesProvider.defaultThumbnailSize.height * 0.8)
            default:
                return .zero
            }
        }
    }
}
// swiftlint:enable multiline_arguments_brackets
