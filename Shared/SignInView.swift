// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI


protocol SignInViewDelegate: AnyObject {
    func signInViewDidTapSignIn(_ signInView: SignInView)
}

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding private var authResponse: AuthorizeResponse?
    private let authClient: AuthorizationClient

    init(
        authClient: AuthorizationClient,
        authResponse: Binding<AuthorizeResponse?>
    ) {
        self.authClient = authClient
        self._authResponse = authResponse
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sign in to Pocket").font(.title)

            Text("Email")
            TextField("", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Text("Password")
            TextField("", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Sign in") {
                authClient.authorize(
                    username: email,
                    password: password
                ) { result in
                    switch result {
                    case .success(let token):
                        self.authResponse = token
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
    }
}
