// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import UIKit

public struct PasteBoardModifier: ViewModifier {
    enum Constants {
        static let imageMaxWidth: CGFloat = 83
        static let spacing: CGFloat = 22
        static let titleStyle: Style = .header.sansSerif.p2.with(weight: .bold).with(color: .ui.black)
        static let cornerRadius: CGFloat = 4
    }

    public struct PasteBoardData {
        var title: String
        var action: PasteBoardAction

        public struct PasteBoardAction {
            var text: String
            var action: (_ url: URL?) -> Void
            var dismiss: () -> Void

            public init(text: String, action: @escaping (_ url: URL?) -> Void, dismiss: @escaping () -> Void) {
                self.text = text
                self.action = action
                self.dismiss = dismiss
            }
        }

        public init(title: String, action: PasteBoardAction) {
            self.title = title
            self.action = action
        }
    }

    let data: PasteBoardData
    let bottomOffset: CGFloat

    @Binding var show: Bool

    @Environment(\.layoutDirection)
    var layoutDirection: LayoutDirection

    public func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if show {
                VStack {
                    HStack(alignment: .center, spacing: Constants.spacing) {
                        if layoutDirection == .leftToRight {
                            title()
                            Spacer()
                            button()
                        } else {
                            button()
                            Spacer()
                            title()
                        }
                    }
                }
                .padding(13)
                .background(Color(.ui.teal6))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Color(.ui.teal5), lineWidth: 1)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("banner")
                .padding()
                .padding(.bottom, bottomOffset)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: show)

                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { value in
                        let verticalAmount = value.translation.height
                        if verticalAmount > 0 {
                            withAnimation {
                                self.show = false
                                data.action.dismiss()
                            }
                        }
                    })
            }
        }
    }

    func title() -> some View {
        Text(data.title)
            .style(Constants.titleStyle)
            .onTapGesture {
                withAnimation {
                    self.show = false
                    data.action.dismiss()
                }
            }
            .accessibilityIdentifier("banner-title")
    }

    func button() -> some View {
        return PasteButton(payloadType: URL.self, onPaste: {urls in
            guard let first = urls.first else { return }
            data.action.action(first)
        })
        .tint(Color(.ui.teal2))
        .labelStyle(.titleOnly)
    }
}

public extension View {
    func pasteboard(data: PasteBoardModifier.PasteBoardData, show: Binding<Bool>, bottomOffset: CGFloat) -> some View {
        self.modifier(PasteBoardModifier(data: data, bottomOffset: bottomOffset, show: show))
    }
}

private extension Style {
    static let title: Self = .header.sansSerif.p2.with(weight: .semibold).with(color: .ui.black).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
    static let subtitle: Self = .header.sansSerif.p4.with(weight: .regular).with(color: .ui.black).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
}

struct PasteBoardModifier_PreviewProvider: PreviewProvider {
    static var previews: some View {
        TabView {
            VStack {
            }.tabItem {
                Image(asset: .tabSettingsSelected)
                Text("Settings")
            }

            VStack {
            }.tabItem {
                Image(asset: .tabSettingsSelected)
                Text("Settings")
            }
        }
        .pasteboard(data: PasteBoardModifier.PasteBoardData(title: "Add copied URL to your Saves?", action: PasteBoardModifier.PasteBoardData.PasteBoardAction(text: "Paste", action: { _ in }, dismiss: {})), show: .constant(true), bottomOffset: 49)
        .previewDisplayName("TabBar")
    }
}
