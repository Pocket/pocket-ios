// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import SharedPocketKit

class URLExtractorTests: XCTestCase {
    func test_extract_whenItemProviderHasURL_returnsURL() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.url"
        }
        itemProvider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")! as NSSecureCoding
        }

        var extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")

        itemProvider.stubLoadItem { _, _ in
            URL(string: "https%3a%2f%2fgetpocket.com")! as NSSecureCoding
        }

        extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")
    }

    func test_extract_whenItemProviderHasURL_asData_returnsURL() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.url"
        }
        itemProvider.stubLoadItem { _, _ in
            URL(string: "https://getpocket.com")!.dataRepresentation as NSSecureCoding
        }

        var extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")

        itemProvider.stubLoadItem { _, _ in
            URL(string: "https%3a%2f%2fgetpocket.com")! as NSSecureCoding
        }

        extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")
    }

    func test_extract_whenItemProviderHasExternalAppURL_returnsURL() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.url"
        }
        itemProvider.stubLoadItem { _, _ in
            // TODO: Funky percent-encoded mumbojumbo
            URL(string: "com.mozilla.pocket://save?url=https://getpocket.com?foo=bar")! as NSSecureCoding
        }

        var extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com?foo=bar")

        itemProvider.stubLoadItem { _, _ in
            // TODO: Funky percent-encoded mumbojumbo
            URL(string: "com.mozilla.pocket://save?url=https%3a%2f%2fgetpocket.com?foo=bar")! as NSSecureCoding
        }

        extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com?foo=bar")
    }

    func test_extract_whenItemProviderHasExternalAppURLWithNoFollowingURL_returnsNil() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.url"
        }
        itemProvider.stubLoadItem { _, _ in
            URL(string: "com.mozilla.pocket://save?this-is-not-a-url")! as NSSecureCoding
        }

        let extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertNil(extracted)
    }

    func test_extract_whenItemProviderHasString_containingOnlyURL_returnsStringAsURL() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.plain-text"
        }
        itemProvider.stubLoadItem { _, _ in
            "https://getpocket.com" as NSSecureCoding
        }

        var extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")

        itemProvider.stubLoadItem { _, _ in
            "https%3a%2f%2fgetpocket.com" as NSSecureCoding
        }

        extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")
    }

    func test_extract_whenItemProviderHasString_containingStringAndURL_returnsStringAsURL() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.plain-text"
        }
        itemProvider.stubLoadItem { _, _ in
            "Hello, world. https://getpocket.com" as NSSecureCoding
        }

        var extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")

        itemProvider.stubLoadItem { _, _ in
            "Hello, world. https%3a%2f%2fgetpocket.com" as NSSecureCoding
        }

        extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")
    }

    func test_extract_whenItemProviderHasStringAndExternalAppURL_returnsURL() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.plain-text"
        }
        itemProvider.stubLoadItem { _, _ in
            "com.mozilla.pocket://save?url=https://getpocket.com" as NSSecureCoding
        }

        var extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com")

        itemProvider.stubLoadItem { _, _ in
            "com.mozilla.pocket://save?url=https%3a%2f%2fgetpocket.com%3Ffoo%3Dbar" as NSSecureCoding
        }

        extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertEqual(extracted, "https://getpocket.com?foo=bar")
    }

    func test_extract_whenItemProviderHasString_containingStringAndNoURL_returnsNil() async {
        let itemProvider = MockItemProvider()
        itemProvider.stubHasItemConformingToTypeIdentifier { id in
            return id == "public.plain-text"
        }
        itemProvider.stubLoadItem { _, _ in
            "Hello, world." as NSSecureCoding
        }

        let extracted = await URLExtractor.url(from: itemProvider)
        XCTAssertNil(extracted)
    }
}
