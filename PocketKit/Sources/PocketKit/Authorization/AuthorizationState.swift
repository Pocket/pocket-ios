import Combine


class AuthorizationState: ObservableObject {
    @Published
    var authToken: AuthorizeResponse?
}
