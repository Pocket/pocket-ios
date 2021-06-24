// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

struct AuthorizeResponse: Codable {
    let accessToken: String
    let username: String
    let account: Account

    enum CodingKeys: String, CodingKey {
        case username
        case account
        case accessToken = "access_token"
    }
}

struct Account: Codable {
    let firstName: String
    let lastName: String
    let userID: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case userID = "user_id"
    }
}
