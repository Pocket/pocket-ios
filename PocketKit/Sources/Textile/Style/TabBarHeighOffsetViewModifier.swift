//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/15/23.
//

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
