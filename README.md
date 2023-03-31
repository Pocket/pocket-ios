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

### Modifiying GraphQL query/mutation in code

To modify/create a request, look into `PocketKit/Sources/PocketGraph/user-defined-operations`

Any modifications done here, and after you generate above, will be auto-generated in our codebase for usage.

To use it in code, prior, we had a singleton `PocketSource`, but we are moving away from that model and instead encourage the use of a protocol Service.  As an example, you can look at `SlateService`.

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

### Swift Previews

Due to the project structure being a Package within an app, Swift previews do not work in the way you would expect. When working on SwiftUI with previews you need to select the build scheme in the xcode menu bar for the package you are working on. I.E. If you are working on a SwiftUI view under PocketKit ensure PocketKit is selected in the scheme editor, if you are working in Textile, make sure Textile is selected.

Also in order to support SwiftUI Previews, view models should not be passed directly into the View and instead the properties and actions should be passed directly. [See this opinion piece for more on the subject.](https://medium.com/swift2go/swiftui-opinion-viewmodel-doesnt-belong-in-previews-62d9e1485b38)

### License Acknowledgements

When you add a dependncy we need to ensure that our [OpenSource Licenses](https://getpocket.com/opensource_licenses_ios) are up to date with all licenses we are using. 

The following are the high level steps to update the notices page:

1. Install [LicensePlist](https://github.com/mono0926/LicensePlist) `brew install licenseplist`
2. Run `license-plist --markdown-path Acknowledgements.markdown`
3. Open an issue on [Bedrock](https://github.com/mozilla/bedrock/) with a description and the requested page to update with a link to a document of the generated `Acknowledgements.markdown`

## Releasing

To release a version of Pocket following our every 2 week cycle you should follow the following depending on your release scenario. The following assumes you will be releasing to the Testflight Audience and then after some time promoting that version of the App to the store.

If you need to increment the app version:
1. If needed pr to increment the app version number in Git on the `develop` branch.
2. Trigger the `nightly-internal-pipeline` manually to submit a new build to Testflight.

If you will use the app version already in `develop`
1. Find the nightly you will promote that is already Testflight Nightlies. Correlate it's build number with Bitrise and find the respective commit and write that down. You can search by build number in the Bitrise UI.
   a. Alternatively trigger the `nightly-internal-pipeline` manually to submit a new build to Testflight from the latest on the `develop` branch.

Once you have the build and associated commit you want to release to the Testflight audience perform the following in Git and Github:
1. Tag the commit in git with the name `release/v0.0.0.0000` where 0.0.0 is the app version, and .0000 is the build number.
2. Push the tag to github.
3. Draft a new GitHub release by [clicking here](https://github.com/Pocket/pocket-ios/releases/new)
4. For the name put `v0.0.0.0000` where 0.0.0 is the app version, and .0000 is the build number.
5. In the 'Choose a tag' dropdown select the tag you pushed to GitHub and make sure the target is `main`. This will draft the release by comparing the changes between the tag and the last release.
6. Click Auto Generate Release Notes.
7. Obtain the public release notes and add it as the last section.
8. Publish the release, or save as draft until you are ready.
9. Once ready, checkout out main locally `git checkout main` 
10. Merge the tag you made into `main` `git merge release/v0.0.0.0000` and push it to GitHub. Alternativly do a PR from the tag to `main` and ensure you merge the PR maintaining history. (otherwise you need to merge main back into develop)

You are now done with the process in Git and Github!

### App Store Connect

Releasing to Beta Testers:

1. Find the build you want to release to testers
2. Add in the public facing release notes in TestFlight.
3. Add the Public Beta and Mozillians Testflight Groups to the build. They will be notified once the app passes External Beta Review and receive the update. Ensure you coordinate this with the Product team.
4. At the same time you should also submit the App for Store review, but set it so that the app is held and we need to release it manually to the store after it is approved. This ensures that after our beta cycle finishes, we can immediately launch that version of the app to the Store.
    a. When you release the App to the beta audience, you should at the same time release the last beta app to the store. *In coordination with the product team.*

