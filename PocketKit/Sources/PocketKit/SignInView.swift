// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Textile

private extension SignInView {
    static let titleStyle: Style = .header.sansSerif.h2
    static let textFieldStyle: Style = .header.sansSerif.h5.with(weight: .regular).with(color: .ui.grey2)
    static let textStyle: Style = .header.sansSerif.h5.with(color: .ui.white1)
}

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

    private var authClient: AuthorizationClient

    @State
    private var email = ""

    @State
    private var password = ""

    @State
    private var error: SignInError?

    var authState: AuthorizationState

    init(authClient: AuthorizationClient, state: AuthorizationState) {
        self.authClient = authClient
        self.authState = state
    }

    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pocket")
                    .style(SignInView.titleStyle)
                TextField("Username or email", text: $email)
                    .style(SignInView.textFieldStyle)
                    .padding(.all, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.ui.grey6), lineWidth: 2)
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .accessibility(identifier: "email")
                SecureField("Password", text: $password)
                    .style(SignInView.textFieldStyle)
                    .padding(.all, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.ui.grey6), lineWidth: 2)
                    )
                    .accessibility(identifier: "password")
            }
            Button{
                self.signIn()
            } label: {
                Text("Sign In")
                    .style(SignInView.textStyle)
                    .frame(maxWidth: 256)
            }
            .alert(item: $error) { error in
                Alert(title: Text(error.localizedDescription))
            }
            .tint(Color(ColorAsset.ui.lapis1))
            .buttonStyle(.bordered)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .colorScheme(.light)
        }
        .padding()
    }

    func signIn() {
        authClient.authorize(
            username: email,
            password: password
        ) { result in
            switch result {
            case .success(let token):
                self.authState.authToken = token
            case .failure(let error):
                Crashlogger.capture(error: error)
                self.error = .signInError(error)
            }
        }
    }
}
