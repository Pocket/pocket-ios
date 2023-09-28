# Contributor guidelines
We'd love for you to contribute to this repository. Before you start, we'd like you to take a look and follow these guidelines:
  - [Submitting an Issue](#submitting-an-issue)
  - [Creating a pull request](#creating-a-pull-request)
  - [Coding Rules](#coding-rules)
    - [Swift style](#swift-style)
    - [Whitespace](#whitespace)
  - [Commits](#commits)
  - [Before Pushing](#before-pushing)


## Submitting an Issue
If you find a bug in the source code or a mistake in the documentation, check our Issues page. It may be that your concern has already been addressed. If you cannot find a satisfying resolution, you can [submit an issue](https://github.com/Pocket/pocket-ios/issues/new/choose).


# Coding Rules

## Swift style
* Swift code should generally follow the conventions listed at https://github.com/raywenderlich/swift-style-guide.
  * Exception: we use 4-space indentation instead of 2.
  * This is a loose standard. We do our best to follow this style


## Whitespace
* Swiftlint will reject any instances of trailing whitespace or whitespace-only lines.
* We recommend enabling both the "Automatically trim trailing whitespace" and "Including whitespace-only lines" preferences in Xcode (under Text Editing).
* <code>git rebase --whitespace=fix</code> can also be used to remove whitespace from your commits before issuing a pull request.


## Commits
* Each commit should have a single clear purpose. If a commit contains multiple unrelated changes, those changes should be split into separate commits.
* If a commit requires another commit to build properly, those commits should be squashed.
* Follow-up commits for any review comments should be squashed. Do not include "Fixed PR comments", merge commits, or other "temporary" commits in pull requests.


### Commit strategy

We prefer to keep out commit history linear (meaning avoiding noisy merge
commits). To keep your branch up to date, follow these steps:

```bash
# while on your PR branch
git checkout develop
git pull --rebase
git checkout my-pr-branch
git rebase develop
git push origin my-pr-branch --force[-with-lease]
```

## Before Pushing
### Running Danger Locally

You can run danger locally to see what it would output by running the following in the root of the repository.

```bash
swift run danger-swift pr [some-pr-url]
```

### UI Tests (Mozillans Only)

UI Tests are split into 3 test plans. As you built UI tests you should ensure that your test is enabled in 1 of the UI test plans to be run on CI in such a way as to balance the 3 test plans. We use Snowplow-micro to test for expected analytics events. As a Mozillain you can get access to our Docker image.


### Localization

Pocket localization is handled by Smartling. The project is currently setup in [Single Branch Mode](https://help.smartling.com/hc/en-us/articles/360008152513-GitHub-Connector-Overview#SingleBranchModeTranslationFlow) against the `develop` branch. Everytime a commit is made to `develop` Smartling will analyze the branch and determine if it needs to start a translation job. 
If it does, it will begin automatically and make a PR back against the repo with the needed translations.
Occasionally our translators may have a question or need some alterations to unblock their work. You can check in the Smartling Dashboard for these queries.


#### Adding Strings

Pocket uses [swiftgen](https://github.com/SwiftGen/SwiftGen#strings) to generate a [Strings.swift](./PocketKit/Sources/PocketKit/Strings.swift) file from our English [Localizable.strings](./PocketKit/Sources/PocketKit/Resouces/en.lproj/Localizable.strings) file.

Moving forward we will use a reverse dns pattern for String keys.
e.g. `"search.results.empty.header" = "No results found";`

To make a new string follow the following steps:
1. Ensure you have `swiftgen` installed (`brew install swiftgen`)
2. Add your string to [Localizable.strings](./PocketKit/Sources/PocketKit/Resouces/en.lproj/Localizable.strings) _Note: If you add a comment above the string, it will be included for the Smartling translators and is useful if a word translated has different transalations based on the usage._
3. Either a) Build the project or b) run `swiftgen` from the root of the Pocket project directory
4. The new string enum should be available in the `Localization` enum for you to use.
5. Once your PR lands in `develop` watch as Smartling will pick it up and translate it.


### Swift Previews

Due to the project structure being a Package within an app, Swift previews do not work in the way you would expect. When working on SwiftUI with previews you need to select the build scheme in the xcode menu bar for the package you are working on. I.E. If you are working on a SwiftUI view under PocketKit ensure PocketKit is selected in the scheme editor, if you are working in Textile, make sure Textile is selected.

Also in order to support SwiftUI Previews, view models should not be passed directly into the View and instead the properties and actions should be passed directly. [See this opinion piece for more on the subject.](https://medium.com/swift2go/swiftui-opinion-viewmodel-doesnt-belong-in-previews-62d9e1485b38)


## Creating a pull request
* All pull requests must be associated with a specific Issue. If an issue doesn't exist please first create it.
* Before you submit your pull request, search the repository for an open or closed Pull Request that relates to your submission. You don't want to duplicate effort. 
