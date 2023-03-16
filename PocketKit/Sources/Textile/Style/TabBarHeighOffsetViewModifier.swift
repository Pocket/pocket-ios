// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// From https://stackoverflow.com/questions/59969911/programmatically-detect-tab-bar-or-tabview-height-in-swiftui

import SwiftUI
struct TabBarHeighOffsetViewModifier: ViewModifier {
    let action: (CGFloat) -> Void
// MARK: this screenSafeArea helps determine the correct tab bar height depending on device version
    private let screenSafeArea = (UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 34)

func body(content: Content) -> some View {
    GeometryReader { proxy in
        content
            .onAppear {
                    let offset = proxy.safeAreaInsets.bottom - screenSafeArea
                    action(offset)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    let offset = proxy.safeAreaInsets.bottom - screenSafeArea
                    action(offset)
            }
        }
    }
}

public extension View {
    func tabBarHeightOffset(perform action: @escaping (CGFloat) -> Void) -> some View {
        modifier(TabBarHeighOffsetViewModifier(action: action))
    }
}
