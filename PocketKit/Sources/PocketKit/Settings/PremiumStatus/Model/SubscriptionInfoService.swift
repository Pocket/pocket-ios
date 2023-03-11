// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Foundation
import Sync

/// Generic type for a service that provides subscription info
public protocol SubscriptionInfoService {
    var info: SubscriptionInfo { get }
    var infoPublisher: Published<SubscriptionInfo>.Publisher { get }
    func getInfo() async throws
}

/// Concrete implementation of SubscriptionInfoService that retrieves subscription info from the V3 AP!
final class PocketSubscriptionInfoService: SubscriptionInfoService {
    @Published var info: SubscriptionInfo = .emptyInfo
    var infoPublisher: Published<SubscriptionInfo>.Publisher { $info }

    private let client: V3ClientProtocol

    init(client: V3ClientProtocol) {
        self.client = client
    }

    func getInfo() async throws {
        info = try await client.premiumStatus().subscriptionInfo
    }
}
