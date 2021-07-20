import Combine


struct Authorization {
    let guid: String
    let response: AuthorizeResponse
}

class AuthorizationState: ObservableObject {
    @Published
    var authorization: Authorization?
}
