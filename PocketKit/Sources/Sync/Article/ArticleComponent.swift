public typealias Markdown = String

public enum ArticleComponent: Codable, Equatable, Hashable {
    case text(TextComponent)
    case image(ImageComponent)
    case divider(DividerComponent)
    case table(TableComponent)
    case heading(HeadingComponent)
    case codeBlock(CodeBlockComponent)
    case video(VideoComponent)
    case bulletedList(BulletedListComponent)
    case numberedList(NumberedListComponent)
    case blockquote(BlockquoteComponent)
    case unsupported(UnsupportedComponent)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TypenameCodingKeys.self)
        let typename = try container.decode(String.self, forKey: .typename)
        let type = ArticleComponentType(rawValue: typename)

        switch type {
        case .text:
            self = try .text(TextComponent(from: decoder))
        case .image:
            self = try .image(ImageComponent(from: decoder))
        case .divider:
            self = try .divider(DividerComponent(from: decoder))
        case .table:
            self = try .table(TableComponent(from: decoder))
        case .heading:
            self = try .heading(HeadingComponent(from: decoder))
        case .codeBlock:
            self = try .codeBlock(CodeBlockComponent(from: decoder))
        case .video:
            self = try .video(VideoComponent(from: decoder))
        case .bulletedList:
            self = try .bulletedList(BulletedListComponent(from: decoder))
        case .numberedList:
            self = try .numberedList(NumberedListComponent(from: decoder))
        case .blockquote:
            self = try .blockquote(BlockquoteComponent(from: decoder))
        case .none:
            self = .unsupported(UnsupportedComponent(type: typename))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TypenameCodingKeys.self)

        switch self {
        case .text(let component):
            try container.encode(ArticleComponentType.text, forKey: .typename)
            try component.encode(to: encoder)
        case .image(let component):
            try container.encode(ArticleComponentType.image, forKey: .typename)
            try component.encode(to: encoder)
        case .divider(let component):
            try container.encode(ArticleComponentType.divider, forKey: .typename)
            try component.encode(to: encoder)
        case .table(let component):
            try container.encode(ArticleComponentType.table, forKey: .typename)
            try component.encode(to: encoder)
        case .heading(let component):
            try container.encode(ArticleComponentType.heading, forKey: .typename)
            try component.encode(to: encoder)
        case .codeBlock(let component):
           try container.encode(ArticleComponentType.codeBlock, forKey: .typename)
           try component.encode(to: encoder)
        case .video(let component):
            try container.encode(ArticleComponentType.video, forKey: .typename)
            try component.encode(to: encoder)
        case .bulletedList(let component):
            try container.encode(ArticleComponentType.bulletedList, forKey: .typename)
            try component.encode(to: encoder)
        case .numberedList(let component):
            try container.encode(ArticleComponentType.numberedList, forKey: .typename)
            try component.encode(to: encoder)
        case .blockquote(let component):
            try container.encode(ArticleComponentType.blockquote, forKey: .typename)
            try component.encode(to: encoder)
        case .unsupported(let component):
            try container.encode(component.type, forKey: .typename)
        }
    }

    private enum ArticleComponentType: String, Encodable {
        case text = "MarticleText"
        case image = "Image"
        case divider = "MarticleDivider"
        case table = "MarticleTable"
        case heading = "MarticleHeading"
        case codeBlock = "MarticleCodeBlock"
        case video = "Video"
        case bulletedList = "MarticleBulletedList"
        case numberedList = "MarticleNumberedList"
        case blockquote = "MarticleBlockquote"
    }

    private enum TypenameCodingKeys: String, CodingKey {
        case typename = "__typename"
    }

    public var isEmpty: Bool {
        switch self {
        case .text(let text):
            return text.isEmpty
        case .heading(let heading):
            return heading.isEmpty
        case .blockquote(let blockquote):
            return blockquote.content.isEmpty
        case .bulletedList(let list):
            return list.rows.isEmpty
        case .codeBlock(let codeBlock):
            return codeBlock.text.isEmpty
        case .numberedList(let list):
            return list.rows.isEmpty
        case .image(let image):
            return image.source == nil
        case .divider, .table, .video, .unsupported:
            return false
        }
    }
}

extension ArticleComponent {
    init(_ marticle: MarticleTextParts) {
        self = .text(TextComponent(marticle))
    }

    init(_ marticle: ImageParts) {
        self = .image(ImageComponent(marticle))
    }

    init(_ marticle: MarticleDividerParts) {
        self = .divider(DividerComponent(marticle))
    }

    init(_ marticle: MarticleTableParts) {
        self = .table(TableComponent(marticle))
    }

    init(_ marticle: MarticleHeadingParts) {
        self = .heading(HeadingComponent(marticle))
    }

    init(_ marticle: MarticleCodeBlockParts) {
        self = .codeBlock(CodeBlockComponent(marticle))
    }

    init(_ marticle: VideoParts) {
        self = .video(VideoComponent(marticle))
    }

    init(_ marticle: MarticleBulletedListParts) {
        self = .bulletedList(BulletedListComponent(marticle))
    }

    init(_ marticle: MarticleNumberedListParts) {
        self = .numberedList(NumberedListComponent(marticle))
    }

    init(_ marticle: MarticleBlockquoteParts) {
        self = .blockquote(BlockquoteComponent(marticle))
    }

    init(_ marticle: ItemParts.Marticle) {
        let fragments = marticle.fragments

        if let parts = fragments.marticleTextParts {
            self.init(parts)
            return
        }

        if let parts = fragments.imageParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleDividerParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleTableParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleHeadingParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleCodeBlockParts {
            self.init(parts)
            return
        }

        if let parts = fragments.videoParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleBulletedListParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleNumberedListParts {
            self.init(parts)
            return
        }

        if let parts = fragments.marticleBlockquoteParts {
            self.init(parts)
            return
        }

        self = .unsupported(UnsupportedComponent(type: marticle.__typename))
    }
}
