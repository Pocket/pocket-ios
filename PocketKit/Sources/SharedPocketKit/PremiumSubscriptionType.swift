// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// An enum that maps all available subscription IDs on the App Store
public enum PremiumSubscriptionType: String, Sendable {
    case monthly
    case annual
    case unknown
}
