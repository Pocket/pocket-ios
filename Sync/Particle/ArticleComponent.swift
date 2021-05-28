// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public enum ArticleComponent: Equatable {
    case bodyText(BodyText)
    case byline(Byline)
    case copyright(Copyright)
    case header(Header)
    case image(ImageComponent)
    case message(Message)
    case pre(Pre)
    case publisherMessage(PublisherMessage)
    case quote(Quote)
    case title(Title)
    case unsupported(String)
}
