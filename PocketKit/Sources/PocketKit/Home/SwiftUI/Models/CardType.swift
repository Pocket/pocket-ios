// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// Identifies the type of a card for analytics purposes
enum CardType {
    case recentSave
    case recommendation
    case sharedWithYou
    case collectionStory
    case slateDetail
    case sharedWithYouDetail
}
