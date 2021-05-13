// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Apollo


extension ApolloClient {
    public static func createDefault() -> ApolloClient {
        let urlStringFromEnvironment = ProcessInfo.processInfo.environment["POCKET_CLIENT_API_URL"]
        let urlString = urlStringFromEnvironment ?? "https://client-api.getpocket.com"
        return ApolloClient(url: URL(string: urlString)!)
    }
}
