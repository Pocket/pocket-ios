// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public protocol FontStyling {
    var h1: Style { get }
    var h2: Style { get }
    var h3: Style { get }
    var h4: Style { get }
    var h5: Style { get }
    var h6: Style { get }
    var body: Style { get }
    var monospace: Style { get }

    func bolding(style: Style) -> Style

    func with(body: Style) -> FontStyling
}
