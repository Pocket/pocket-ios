// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension ArticleComponent: Decodable {
    private enum ComponentType: String, Decodable {
        case bodyText = "BodyText"
        case quote = "Quote"
        case pre = "Pre"
        case title = "Title"
        case byline = "Byline"
        case message = "Message"
        case copyright = "Copyright"
        case publisherMessage = "PublisherMessage"
        case header = "Header"
        case image = "Image"
    }

    enum ComponentTypeKey: String, Swift.CodingKey {
        case type = "_type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ComponentTypeKey.self)
        let rawType = try container.decode(String.self, forKey: .type)

        guard let componentType = ComponentType(rawValue: rawType) else {
            self = .unsupported(rawType)
            Crashlogger.capture(message: "Encountered unsupported \(ArticleComponent.self) type: \(rawType)")
            return
        }

        switch componentType {
        case .bodyText:
            self = try .bodyText(BodyText(from: decoder))
        case .byline:
            self = try .byline(Byline(from: decoder))
        case .copyright:
            self = try .copyright(Copyright(from: decoder))
        case .header:
            self = try .header(Header(from: decoder))
        case .image:
            self = try .image(ImageComponent(from: decoder))
        case .message:
            self = try .message(Message(from: decoder))
        case .pre:
            self = try .pre(Pre(from: decoder))
        case .publisherMessage:
            self = try .publisherMessage(PublisherMessage(from: decoder))
        case .quote:
            self = try .quote(Quote(from: decoder))
        case .title:
            self = try .title(Title(from: decoder))
        }
    }
}

