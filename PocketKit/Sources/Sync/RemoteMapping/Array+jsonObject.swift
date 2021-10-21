import Apollo


extension Array where Element: GraphQLSelectionSet {
    public var jsonObject: [JSONObject] {
        map { $0.jsonObject }
    }
}
