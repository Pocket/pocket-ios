// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct LaunchEnvironment {
    let v3BaseURL: String
    let clientAPIURL: String
    let snowplowIdentifier: String
    let snowplowEndpoint: String
    let snowplowPostPath: String
    let accessToken: String?
    let sessionGUID: String?
    let sessionUserID: String?

    init(
        v3BaseURL: String = "http://localhost:8080",
        clientAPIURL: String = "http://localhost:8080/graphql",
        snowplowIdentifier: String = "pocket-ios-next-dev",
        snowplowEndpoint: String = "http://localhost:9090",
        snowplowPostPath: String = "com.snowplowanalytics.snowplow/tp2",
        accessToken: String?,
        sessionGUID: String?,
        sessionUserID: String?
    ) {
        self.v3BaseURL = v3BaseURL
        self.clientAPIURL = clientAPIURL
        self.snowplowIdentifier = snowplowIdentifier
        self.snowplowEndpoint = snowplowEndpoint
        self.snowplowPostPath = snowplowPostPath
        self.accessToken = accessToken
        self.sessionGUID = sessionGUID
        self.sessionUserID = sessionUserID
    }

    func toDictionary() -> [String: String] {
        var env = [
           "POCKET_V3_BASE_URL": v3BaseURL,
           "POCKET_CLIENT_API_URL": clientAPIURL,
           "SNOWPLOW_IDENTIFIER": snowplowIdentifier,
           "SNOWPLOW_ENDPOINT": snowplowEndpoint,
           "SNOWPLOW_POST_PATH": snowplowPostPath
       ]

        if let accessToken = accessToken {
            env["accessToken"] = accessToken
        }
        if let sessionGUID = sessionGUID {
            env["sessionGUID"] = sessionGUID
        }
        if let sessionUserID = sessionUserID {
            env["sessionUserID"] = sessionUserID
        }

        return env
    }
}

extension LaunchEnvironment {
    static let withSession = LaunchEnvironment(
        accessToken: "test-access-token",
        sessionGUID: "session-guid",
        sessionUserID: "session-user-id"
    )

    static let noSession = LaunchEnvironment(
        accessToken: nil,
        sessionGUID: nil,
        sessionUserID: nil
    )

    static let anonymousSession = LaunchEnvironment(
        accessToken: "",
        sessionGUID: "",
        sessionUserID: ""
    )
}
