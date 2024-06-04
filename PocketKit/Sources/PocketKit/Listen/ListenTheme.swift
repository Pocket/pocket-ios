// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import PKTListen
import Textile

final class ListenTheme: NSObject, PKTUITheme, Sendable {
    func white() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.gray1)
        }

        return UIColor(.listen.white)
    }

    func amber() -> UIColor! {
        return UIColor(.listen.amber)
    }

    func amberTouch() -> UIColor! {
        return UIColor(.listen.amberTouch)
    }

    func blue() -> UIColor! {
        return UIColor(.listen.blue)
    }

    func blueTouch() -> UIColor! {
        return UIColor(.listen.blueTouch)
    }

    func teal() -> UIColor! {
        return UIColor(.listen.teal)
    }

    func tealLight() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.darkTeal)
        }

        return UIColor(.listen.tealLight)
    }

    func darkTeal() -> UIColor! {
        return UIColor(.listen.darkTeal)
    }

    func mintGreen() -> UIColor! {
        return UIColor(.listen.mintGreen)
    }

    func coral() -> UIColor! {
        return UIColor(.listen.coral)
    }

    func coralTouch() -> UIColor! {
        return UIColor(.listen.coralTouch)
    }

    func coralLight() -> UIColor! {
        return UIColor(.listen.coralLight)
    }

    func darkTealSelection() -> UIColor! {
        return UIColor(.listen.darkTealSelection)
    }

    func purle() -> UIColor! {
        return UIColor(.listen.purple)
    }

    func gray1() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.white)
        }

        return UIColor(.listen.gray1)
    }

    func gray2() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.gray3)
        }

        return UIColor(.listen.gray2)
    }

    func gray3() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.gray4)
        }

        return UIColor(.listen.gray3)
    }

    func gray4() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.gray5)
        }

        return UIColor(.listen.gray4)
    }

    func gray5() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.gray2)
        }

        return UIColor(.listen.gray5)
    }

    func gray6() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return UIColor(.listen.black)
        }

        return UIColor(.listen.gray6)
    }

    func tileStartFadeColor() -> UIColor! {
        let alphaComponent = UITraitCollection.current.userInterfaceStyle == .dark ? 0.5 : 0.05
        return .black.withAlphaComponent(alphaComponent)
    }

    func tileEndFadeColor() -> UIColor! {
        return .black.withAlphaComponent(0)
    }

    func highlightTextColor() -> UIColor! {
        // Legacy light mode and dark mode both use the light mode color
        return UIColor(.listen.gray1).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
    }

    func highlightBackgroundColor() -> UIColor! {
        // Legacy light mode and dark mode both use the light mode color
        return UIColor(.listen.amberTouch).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
    }

    func disabledTextColor() -> UIColor! {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            // Legacy dark mode uses the light mode color
            return UIColor(.listen.gray3).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        }

        return UIColor(.listen.gray4)
    }

    func tagSelectedBackgroundColor() -> UIColor! {
        return UIColor(.ui.grey7)
    }

    func inListBigDiamond() -> UIImage! {
        return UIImage(asset: .diamond)
    }

    func statusBarStyle() -> UIStatusBarStyle {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .lightContent
        }

        return .darkContent
    }

    func scrollViewIndicatorStyle() -> UIScrollView.IndicatorStyle {
        if UITraitCollection.current.userInterfaceStyle == .dark {
            return .white
        }

        return .black
    }
}
