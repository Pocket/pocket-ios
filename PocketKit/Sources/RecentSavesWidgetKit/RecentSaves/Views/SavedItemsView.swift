// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// swiftlint:disable multiline_arguments_brackets
import Foundation
import Localization
import SwiftUI
import Textile
import WidgetKit

/// Recent Saves widget - recent saves list view
struct SavedItemsView: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    let items: [SavedItemRowContent]

    var body: some View {
        VStack(alignment: .leading) {
            Text(AttributedString(NSAttributedString(string: Localization.Widgets.RecentSaves.title, style: .widgetHeader(for: widgetFamily))))
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.bottom, Size.bottomHeaderPadding(for: widgetFamily))
            ForEach(items) { entry in
                SavedItemRow(title: entry.content.title.isEmpty ? entry.content.url : entry.content.title,
                             domain: entry.content.bestDomain,
                             readingTime: entry.content.readingTime,
                             image: entry.image)
                .padding(.top, Size.cellPadding(for: widgetFamily))
                .padding(.bottom, Size.cellPadding(for: widgetFamily))
                .padding(.leading, 16)
                .padding(.trailing, 16)
            }
        }
    }
}

/// Recent Saves widget - saved item view
struct SavedItemRow: View {
    @Environment(\.widgetFamily)
    private var widgetFamily

    let title: String
    let domain: String
    let readingTime: String?
    let image: Image?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top) {
                Text(AttributedString(NSAttributedString(string: title, style: .widgetTitle(for: widgetFamily))))
                Spacer()
                if let image {
                    ItemThumbnail(image: image)
                }
            }
            .lineLimit(3)
            if let readingTime {
                Text(AttributedString(NSAttributedString(string: domain + " - " + readingTime, style: .domain)))
            } else {
                Text(AttributedString(NSAttributedString(string: domain, style: .domain)))
            }
        }
    }
}

/// Recent Saves widget - saved item thumbnail
struct ItemThumbnail: View {
    let image: Image

    var body: some View {
        image
            .resizable()
            .frame(
                width: RecentSavesProvider.defaultThumbnailSize.width,
                height: RecentSavesProvider.defaultThumbnailSize.height
            )
            .cornerRadius(8)
    }
}

private extension Style {
    static let domain: Style = .header.sansSerif.p5.with(color: .ui.grey8).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }
    static func widgetHeader(for widgetFamily: WidgetFamily) -> Style {
        if widgetFamily == .systemLarge {
            return .header.sansSerif.h7.with(color: .ui.teal2)
        }
        return .header.sansSerif.p4.with(color: .ui.teal2)
    }

    static func widgetTitle(for widgetFamily: WidgetFamily) -> Style {
        if widgetFamily == .systemLarge {
            return .header.sansSerif.h7.with(color: .ui.black1).with { paragraph in
                paragraph.with(lineBreakMode: .byTruncatingTail).with(lineSpacing: 4)
            }
        } else {
            return .header.sansSerif.h8.with(color: .ui.black1).with { paragraph in
                paragraph.with(lineBreakMode: .byTruncatingTail).with(lineSpacing: 4)
            }
        }
    }
}

// MARK: formatting
private extension SavedItemsView {
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
    }
}
// swiftlint:enable multiline_arguments_brackets
