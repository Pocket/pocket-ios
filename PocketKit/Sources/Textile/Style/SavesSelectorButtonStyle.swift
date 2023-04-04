// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI

public struct SavesSelectorButtonStyle: ButtonStyle {
    private struct Constants {
        static let cornerRadius: CGFloat = 16
        static let selected: Style = .header.sansSerif.h6
        static let title: Style = .header.sansSerif.h8
        static let padding: CGFloat = 8
        static let selectedBackground: Color = Color(.ui.teal6)
    }

    let isSelected: Binding<Bool>
    let image: Image
    let title: String

    public init(isSelected: Binding<Bool>, image: Image, title: String) {
        self.isSelected = isSelected
        self.image = image
        self.title = title
    }

    public func makeBody(configuration: Configuration) -> some View {
        SavesSelectorButton(configuration: configuration, isSelected: self.isSelected, image: self.image, title: self.title)
    }

    struct SavesSelectorButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled)
        private var isEnabled: Bool

        @Binding var isSelected: Bool

        var image: Image
        var title: String

        var body: some View {
            HStack {
                image

                if isSelected {
                    Text(title)
                        .style(isSelected ? Constants.selected : Constants.title)
                }
            }
            .foregroundColor(isSelected ? Color(.ui.teal1) : Color(.ui.grey1))
            .padding(Constants.padding)
            .background(isSelected ? Constants.selectedBackground : .clear)
            .cornerRadius(Constants.cornerRadius)
        }
    }
}

struct SavesSelectorButton_PreviewProvider: PreviewProvider {
    static var previews: some View {
        VStack {
            HStack {
                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(true), image: Image(asset: .saves), title: "Saves"))

                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(false), image: Image(asset: .archive), title: "Archive"))
            }
            HStack {
                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(false), image: Image(asset: .saves), title: "Saves"))

                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(true), image: Image(asset: .archive), title: "Archive"))
            }
        }
        .previewDisplayName("Enabled - Light")
        .preferredColorScheme(.light)

        VStack {
            HStack {
                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(true), image: Image(asset: .saves), title: "Saves"))

                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(false), image: Image(asset: .archive), title: "Archive"))
            }
            HStack {
                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(false), image: Image(asset: .saves), title: "Saves"))

                Button(action: {}) {}
                    .buttonStyle(SavesSelectorButtonStyle(isSelected: .constant(true), image: Image(asset: .archive), title: "Archive"))
            }
        }
        .previewDisplayName("Enabled - Dark")
        .preferredColorScheme(.dark)
    }
}
