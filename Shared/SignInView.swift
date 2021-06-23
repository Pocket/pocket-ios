// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sentry


struct SignInView: View {
    enum SignInError: Error, Identifiable {
        case signInError(Error)

        var localizedDescription: String {
            switch self {
            case .signInError(let error):
                return error.localizedDescription
            }
        }

        var id: String {
            return "\(self)"
        }
    }

    @Environment(\.authorizationClient)
    private var authClient: AuthorizationClient

    @Environment(\.accessTokenStore)
    private var accessTokenStore: AccessTokenStore

    @State
    private var email = ""

    @State
    private var password = ""

    @State
    private var error: SignInError?

    @Binding
    var authToken: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sign in to Pocket").font(.title)

            Text("Email")
            TextField("Email", text: $email)
                .accessibility(identifier: "email")
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.emailAddress)

            Text("Password")
            SecureField("", text: $password)
                .accessibility(identifier: "password")
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Sign in") {
                self.signIn()
            }.alert(item: $error) { error in
                Alert(title: Text(error.localizedDescription))
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }

    func signIn() {
        authClient.authorize(
            username: email,
            password: password
        ) { result in
            switch result {
            case .success(let token):
                do {
                    try accessTokenStore.save(token: token.accessToken)
                    SentrySDK.setUser(User(userId: token.account.userID))
                } catch {
                    self.error = .signInError(error)
                    return
                }

                DispatchQueue.main.async {
                    self.authToken = token.accessToken
                }
            case .failure(let error):
                self.error = .signInError(error)
            }
        }
    }
}
