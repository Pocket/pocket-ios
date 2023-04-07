// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// Tracks the action that dismisses a sheet
public enum DismissReason: String {
    case swipe
    case button
    case system
    case closeButton
}
