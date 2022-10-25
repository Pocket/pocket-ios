import XCTest
import PocketGraph
import ApolloAPI
@testable import Sync

class ArticleComponentTests: XCTestCase {
    func test_decode_whenTypeIsMarticleText_returnsATextComponent() throws {
        let json = """
        {
            "__typename": "MarticleText",
            "content": "Commodo Consectetur Dapibus"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .text(let textComponent) = component else {
            XCTFail("Expected a text component but got \(component)")
            return
        }
        XCTAssertEqual(textComponent.content, "Commodo Consectetur Dapibus")
    }

    func test_encode_whenTextCase_isRoundtrippable() throws {
        let component: ArticleComponent = .text(TextComponent(content: "some markdown"))
        let other = try roundtrip(component)

        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsImage_returnsAnImageComponent() throws {
        let json = """
        {
            "__typename": "Image",
            "caption": "Ligula Inceptos",
            "credit": "Bibendum Vestibulum Mollis Sollicitudin Cursus",
            "height": 1,
            "width": 2,
            "imageID": 3,
            "src": "http://example.com/image-3.jpg"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .image(let imageComponent) = component else {
            XCTFail("Expected a image component but got \(component)")
            return
        }

        XCTAssertEqual(imageComponent.caption, "Ligula Inceptos")
        XCTAssertEqual(imageComponent.credit, "Bibendum Vestibulum Mollis Sollicitudin Cursus")
        XCTAssertEqual(imageComponent.height, 1)
        XCTAssertEqual(imageComponent.width, 2)
        XCTAssertEqual(imageComponent.id, 3)
        XCTAssertEqual(imageComponent.source, URL(string: "http://example.com/image-3.jpg")!)
    }

    func test_decode_whenTypeIsImage_andURLContainsASpace_properlyParsesTheURL() throws {
        let json = """
        {
            "__typename": "Image",
            "caption": "Ligula Inceptos",
            "credit": "Bibendum Vestibulum Mollis Sollicitudin Cursus",
            "height": 1,
            "width": 2,
            "imageID": 3,
            "src": "http://example.com/image 3.jpg"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .image(let imageComponent) = component else {
            XCTFail("Expected a image component but got \(component)")
            return
        }

        XCTAssertEqual(imageComponent.source?.absoluteString, "http://example.com/image%203.jpg")
    }

    func test_encode_whenImageCase_isRoundtrippable() throws {
        let component: ArticleComponent = .image(
            ImageComponent(
                caption: "a caption",
                credit: "a credit",
                height: 1,
                width: 2,
                id: 3,
                source: URL(string: "http://example.com")!
            )
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_initWithMarticle_withImageParts_handlesSpacesInSourceURL() throws {

        let parts = ImageParts(data: DataDict([
            "caption": "hello",
            "credit": "world",
            "imageID": 1,
            "src": "http://example.com/image 3.jpg",
            "height": 0,
            "width": 0,
        ], variables: nil))

        let component = ImageComponent(parts)
        XCTAssertEqual(component.source?.absoluteString, "http://example.com/image%203.jpg")
    }

    func test_decode_whenTypeIsMarticleDivider_returnsDividerComponent() throws {
        let json = """
        {
            "__typename": "MarticleDivider",
            "content": "---"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .divider(let dividerComponent) = component else {
            XCTFail("Expected a divider component but got \(component)")
            return
        }

        XCTAssertEqual(dividerComponent.content, "---")
    }

    func test_encode_whenDividerCase_isRoundtrippable() throws {
        let component: ArticleComponent = .divider(
            DividerComponent(content: "---")
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsMarticleTable_returnsTableComponent() throws {
        let json = """
        {
            "__typename": "MarticleTable",
            "html": "<table></table>"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .table(let tableComponent) = component else {
            XCTFail("Expected a table component but got \(component)")
            return
        }

        XCTAssertEqual(tableComponent.html, "<table></table>")
    }

    func test_encode_whenTableCase_isRoundtrippable() throws {
        let component: ArticleComponent = .table(TableComponent(html: "<some><html>"))

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsMarticleHeading_returnsHeadingComponent() throws {
        let json = """
        {
            "__typename": "MarticleHeading",
            "content": "# Purus Vulputate",
            "level": 1
        }
        """

        let component = try decodeComponent(from: json)
        guard case .heading(let heading) = component else {
            XCTFail("Expected a heading component but got \(component)")
            return
        }

        XCTAssertEqual(heading.content, "# Purus Vulputate")
        XCTAssertEqual(heading.level, 1)
    }

    func test_encode_whenHeadingCase_isRoundtrippable() throws {
        let component: ArticleComponent = .heading(HeadingComponent(content: "---", level: 1))

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsMarticleCodeBlock_returnsCodeBlockComponent() throws {
        let json = """
        {
            "__typename": "MarticleCodeBlock",
            "language": 1,
            "text": "<some><code>"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .codeBlock(let codeBlock) = component else {
            XCTFail("Expected a codeblock component but got \(component)")
            return
        }

        XCTAssertEqual(codeBlock.language, 1)
        XCTAssertEqual(codeBlock.text, "<some><code>")
    }

    func test_encode_whenCodeBlockCase_isRoundtrippable() throws {
        let component: ArticleComponent = .codeBlock(
            CodeBlockComponent(language: 0, text: "print(\"hello world\")")
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsVideo_returnsVideoComponent() throws {
        let json = """
        {
            "__typename": "Video",
            "height": 1,
            "src": "http://example.com/video-1.jpg",
            "type": "YOUTUBE",
            "vid": "Aenean Fusce",
            "videoID": 1,
            "width": 2,
            "length": 2
        }
        """

        let component = try decodeComponent(from: json)
        guard case .video(let video) = component else {
            XCTFail("Expected a video component but got \(component)")
            return
        }

        XCTAssertEqual(video.height, 1)
        XCTAssertEqual(video.source, URL(string: "http://example.com/video-1.jpg")!)
        XCTAssertEqual(video.type, .youtube)
        XCTAssertEqual(video.vid, "Aenean Fusce")
        XCTAssertEqual(video.id, 1)
        XCTAssertEqual(video.width, 2)
        XCTAssertEqual(video.length, 2)
    }

    func test_encode_whenVideoCase_isRoundtrippable() throws {
        let component: ArticleComponent = .video(
            VideoComponent(
                id: 0,
                type: .html5,
                source: URL(string: "http://example.com/html5")!,
                vid: "some-vid",
                width: 320,
                height: 240,
                length: 5
            )
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsMarticleBulletedList_returnsBulletedListComponent() throws {
        let json = """
        {
            "__typename": "MarticleBulletedList",
            "rows": [
                {
                    "__typename": "BulletedListElement",
                    "content": "Pharetra Dapibus Ultricies",
                    "level": 1
                }
            ]
        }
        """

        let component = try decodeComponent(from: json)
        guard case .bulletedList(let bulletedList) = component else {
            XCTFail("Expected a bulleted list component but got \(component)")
            return
        }

        XCTAssertEqual(bulletedList.rows[0].content, "Pharetra Dapibus Ultricies")
        XCTAssertEqual(bulletedList.rows[0].level, 1)
    }

    func test_encode_whenBulletedListCase_isRoundtrippable() throws {
        let component: ArticleComponent = .bulletedList(
            BulletedListComponent(
                rows: [
                    BulletedListComponent.Row(
                        content: "# A heading",
                        level: 1
                    )
                ]
            )
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsMarticleNumberedList_returnsNumberedListComponent() throws {
        let json = """
        {
            "__typename": "MarticleNumberedList",
            "rows": [
                {
                    "__typename": "NumberedListElement",
                    "content": "Amet Commodo Fringilla",
                    "level": 2,
                    "index": 1
                }
            ]
        }
        """

        let component = try decodeComponent(from: json)
        guard case .numberedList(let numberedList) = component else {
            XCTFail("Expected a numbered list component but got \(component)")
            return
        }

        XCTAssertEqual(numberedList.rows[0].content, "Amet Commodo Fringilla")
        XCTAssertEqual(numberedList.rows[0].level, 2)
        XCTAssertEqual(numberedList.rows[0].index, 1)
    }

    func test_encode_whenNumberedListCase_isRoundtrippable() throws {
        let component: ArticleComponent = .numberedList(
            NumberedListComponent(
                rows: [
                    NumberedListComponent.Row(content: "# A row", level: 1, index: 1)
                ]
            )
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsMarticleBlockquote_returnsBlockquoteComponent() throws {
        let json = """
        {
            "__typename": "MarticleBlockquote",
            "content": "Pellentesque Ridiculus Porta"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .blockquote(let blockquote) = component else {
            XCTFail("Expected a blockquote component but got \(component)")
            return
        }

        XCTAssertEqual(blockquote.content, "Pellentesque Ridiculus Porta")
    }

    func test_encode_whenBlockquoteCase_isRoundtrippable() throws {
        let component: ArticleComponent = .blockquote(
            BlockquoteComponent(content: "With great power comes great responsibility")
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    func test_decode_whenTypeIsNotRecognized_returnsUnsupportedComponent() throws {
        let json = """
        {
            "__typename": "SomethingReallyStrange",
            "content": "Pellentesque Ridiculus Porta"
        }
        """

        let component = try decodeComponent(from: json)
        guard case .unsupported(let unsupported) = component else {
            XCTFail("Expected an unsupported component but got \(component)")
            return
        }

        XCTAssertEqual(unsupported.type, "SomethingReallyStrange")
    }

    func test_encode_whenUnsupportedCase_isRoundtrippable() throws {
        let component: ArticleComponent = .unsupported(
            UnsupportedComponent(type: "SomethingReallyStrange")
        )

        let other = try roundtrip(component)
        XCTAssertEqual(component, other)
    }

    private func decodeComponent(from jsonString: String) throws -> ArticleComponent {
        let decoder = JSONDecoder()
        let json = jsonString.data(using: .utf8)

        return try decoder.decode(ArticleComponent.self, from: json!)
    }

    private func roundtrip(_ component: ArticleComponent) throws -> ArticleComponent {
        let data = try JSONEncoder().encode(component)
        return try JSONDecoder().decode(ArticleComponent.self, from: data)
    }
}
