// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync


extension Article {
    static let sample = Article(
        content: [
            .title(
                Title(
                    text: TextContent(
                        text:"Venenatis Ridiculus Vehicula"
                    )
                )
            ),

            .byline(Byline(text: TextContent(text: "By Jacob & David"))),

            .message(
                Message(
                    text: TextContent(text: """
                    Vestibulum id ligula porta felis euismod semper. Integer
                    posuere erat a ante venenatis dapibus posuere velit aliquet.
                    """.replacingOccurrences(of: "\n", with: "")
                    )
                )
            ),

            .header(Header(level: 2, text: TextContent(text: "Euismod Ipsum Mollis"))),

            .bodyText(
                BodyText(
                    text: TextContent(
                        text: """
                        Maecenas faucibus mollis interdum. Etiam porta sem
                        malesuada magna mollis euismod. Cum sociis natoque
                        penatibus et magnis dis parturient montes, nascetur
                        ridiculus mus. Sed posuere consectetur est at lobortis.
                        Aenean lacinia bibendum nulla sed consectetur.
                        """.replacingOccurrences(of: "\n", with: "")
                    )
                )
            ),

            .header(Header(level: 3, text: TextContent(text: "Dolor Pharetra Parturient Egestas"))),

            .bodyText(
                BodyText(
                    text: TextContent(
                        text: """
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum
                        id ligula porta felis euismod semper. Vestibulum id ligula porta
                        felis euismod semper. Praesent commodo cursus magna, vel scelerisque
                        nisl consectetur et. Vestibulum id ligula porta felis euismod semper.
                        """.replacingOccurrences(of: "\n", with: "")
                    )
                )
            ),

            .header(Header(level: 3, text: TextContent(text: "Ornare Mollis Magna Ipsum"))),

            .bodyText(
                BodyText(
                    text: TextContent(
                        text: """
                        Etiam porta sem malesuada magna mollis euismod. Lorem ipsum dolor sit amet,
                        consectetur adipiscing elit. Fusce dapibus, tellus ac
                        cursus commodo, tortor mauris condimentum nibh, ut
                        fermentum massa justo sit amet risus. Sed posuere
                        consectetur est at lobortis.
                        """.replacingOccurrences(of: "\n", with: "")
                    )
                )
            ),

            .header(Header(level: 2, text: TextContent(text: "Inline Modifiers"))),
            .bodyText(
                BodyText(
                    text: TextContent(
                        text: """
                        Any text component can include inline modifiers. Inline modifiers
                        come in two flavors: InlineLink and InlineStyle.
                        An InlineLink represents a hyperlink to another webpage and
                        InlineStyle represents a specific style that should be
                        applied to a segment of text (e.g. bold or italic)
                        """.replacingOccurrences(of: "\n", with: "")
                    )
                )
            ),

            .header(Header(level: 3, text: TextContent(text: "Link"))),
            .bodyText(
                BodyText(
                    text: TextContent(
                        text: """
                        This paragraph contains a link to my favorite website of all time.
                        Tapping a link navigates the user to the given URL via a webview.
                        """.replacingOccurrences(of: "\n", with: ""),
                        modifiers: [
                            .link(InlineLink(start: 37, length: 28, address: URL(string: "http://example.com")!))
                        ]
                    )
                )
            ),

            .header(Header(level: 3, text: TextContent(text: "Inline Styles"))),
            .bodyText(
                BodyText(
                    text: TextContent(
                        text: """
                        This paragraph contains a few inline styles. Inline styles have support for
                        a variety of effects. Including bold & strong, italicized,
                        small, and strikethrough text.
                        """.replacingOccurrences(of: "\n", with: ""),
                        modifiers: [
                            .style(InlineStyle(start: 107, length: 4, style: .bold)),
                            .style(InlineStyle(start: 114, length: 6, style: .strong)),
                            .style(InlineStyle(start: 122, length: 10, style: .italic)),
                            .style(InlineStyle(start: 134, length: 5, style: .small)),
                            .style(InlineStyle(start: 145, length: 13, style: .strike)),
                        ]
                    )
                )
            ),

            .copyright(Copyright(text: TextContent(text: "Copyright Pocket 2021")))
        ]
    )
}
