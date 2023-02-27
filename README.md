# Pocket iOS

Welcome to the Next iteration of the Pocket iOS client, currently in development.

# Getting Started

## Setup Pocket Secrets File

To develop Pocket for iOS, you need to first obtain a 1st party Pocket consumer key, which is available to internal Pocket & Mozilla Employees.

Once obtained you can run the following command from the root directory:

```
cp Config/secrets.xcconfig.example Config/secrets.xcconfig
```

Then replace values in `Config/secrets.xcconfig` with the values you have received.

After you will need to run the API Generation steps below.

## Setup Fonts

Pocket use's a custom font called Graphik for it's UI. In order for the styles to present as expected in your local build you need to obtain the font files from the iOS manager and install them in [`PocketKit/Sources/Textile/Style/Typography/Fonts`](./PocketKit/Sources/Textile/Style/Typography/Fonts)


## Pocket Graph (API) Schema

Pocket for iOS uses Apollo client to autogenerate its API schema code. You will need to run the following commands every time the APIs you use change or if you change your API queries.

To Start run the following command:

```bash
cd PocketKit/
swift package --allow-writing-to-package-directory apollo-cli-install
```

### Downloading Graph Schema

To download a new version of [`PocketKit/Sources/Sync/schema.graphqls`](./PocketKit/Sources/Sync/schema.graphqls) you can run the following commands:

```bash
cd PocketKit/
./apollo-ios-cli fetch-schema
```

### Generating API.swift

To download a new version of [`PocketKit/Sources/Sync/API.swift`](./PocketKit/Sources/Sync/API.swift) you can run the following commands:

```bash
cd PocketKit/
./apollo-ios-cli generate
```

### Future

We plan on implementing the following changes in the future:

- Ensure that the [`PocketKit/Sources/PocketGraph/schema.graphqls`](./PocketKit/Sources/PocketGraph/schema.graphqls) and [`PocketKit/Sources/PocketGraph/`](./PocketKit/Sources/PocketGraph/) are generated on demand at build time.
  - Blocked by needing [Swift Build Tool support in Apollo](https://github.com/apollographql/apollo-ios/pull/2464)

## Build Targets

### Pocket Kit

Pocket Kit is the foundation of all of Pocket. Pocket is purposefully abstracted into a Kit so that we can define multiple targets in the Apple Ecosystem and still use the same code base. Here you can find the view controllers, app delegates and most entrypoints into the Pocket application.

### Sync

Sync is the main API & Core Data layer that Pocket is built on. This library provides the work needed to communicate with the Pocket API and our Offline storage layer, backed by CoreData.

### Textile

Textile provides the standard views and styles that can be re-used across all of the Pocket targets we create in the Apple Ecosystem.

### Analytics

Analytics provides Pocket's implementation of [Snowplow](https://github.com/snowplow/) which we use to provide a feedback loop to the Pocket product team into how our features are used.

### Save To Pocket Kit

Save to Pocket Kit is the code base needed to make the Pocket Share Extension function and is embeded in the SaveToPocket Extension that enables you to Save to Pocket from other applications.

### Shared Pocket Kit

Shared Pocket Kit contains the main bits for session management and keychain storage that is used across all apps in the Pocket App Group.

## Developing in Pocket

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

### Running Danger Locally

You can run danger locally to see what it would output by running the following in the root of the repository.

```bash
swift run danger-swift pr [some-pr-url]
```

### Localization

Pocket localization is handled by Smartling. The project is currently setup in [Single Branch Mode](https://help.smartling.com/hc/en-us/articles/360008152513-GitHub-Connector-Overview#SingleBranchModeTranslationFlow) against the `develop` branch. Everytime a commit is made to `develop` Smartling will analyze the branch and determine if it needs to start a translation job. If it does, it will begin automatically and make a PR back against the repo with the needed translations.

#### Adding Strings

Pocket uses [swiftgen](https://github.com/SwiftGen/SwiftGen#strings) to generate a [Strings.swift](./PocketKit/Sources/PocketKit/Strings.swift) file from our English [Localizable.strings](./PocketKit/Sources/PocketKit/Resouces/en.lproj/Localizable.strings) file.

Moving forward we also plan to use a reverse dns pattern for String keys.

To make a new string follow the following steps:
1. Ensure you have `swiftgen` installed (`brew install swiftgen`)
2. Add your string to [Localizable.strings](./PocketKit/Sources/PocketKit/Resouces/en.lproj/Localizable.strings) _Note: If you add a comment above the string, it will be included for the Smartling translators and is useful if a word translated has different transalations based on the usage._
3. Either a) Build the project or b) run `swiftgen` from the root of the Pocket project directory
4. The new string enum should be available in the `L10n` enum for you to use.
5. Once your PR lands in `develop` watch as Smartling will pick it up and translate it.


### UI Tests

UI Tests are split into 3 test plans. As you built UI tests you should ensure that your test is enabled in 1 of the UI test plans to be run on CI.

#### UI Tests & Analytics

All UI Tests rely on [Snowplow Micro](https://github.com/snowplow-incubator/snowplow-micro) to be run. This is because we do validation of our analytics as the UI Tests run and execute them.

To run UI tests ensure you have Docker installed, a part of the Pocket Docker organization and are logged into Docker. Then you can run `docker compose up` from the root of the Pocket directory. This will make Snowplow micro available at http://localhost:9090.

Snowplow micro has 4 endpoints of note:
1. http://localhost:9090/micro/all - Lists the total number of events received and whether they are bad or good.
2. http://localhost:9090/micro/good - Returns all the good (passed validation) events snowplow received and the data within.
3. http://localhost:9090/micro/bad - Returns all the bad (failed validation) events snowplow received and the reason why.
3. http://localhost:9090/micro/reset - Resets snowplow to 0 events received. Should be ran at the start of each test.

[SnowplowMicro](./Tests iOS/Support/SnowplowMicro) class is used to interact with Snowplow and provide helper assertions to make testing events easier.
