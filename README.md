# Pocket iOS

Welcome to the Next iteration of the Pocket iOS client, currently in development.

# Getting Started

## Setup Pocket Secrets File

pocket-ios requires a secrets.xcconfig file to run and secrets_test.xcconfig file to test, we have included some mock secrets in the repo but if you are a Mozillan or Pocketeer you can obtain the actual secret keys from the Pocket Team.

In the future, we plan to allow external contributors to generate their own secrets and be able to build Pocket on their own.

Once obtained you can run the following command from the root directory:

```
cp Config/secrets.xcconfig.example Config/secrets.xcconfig
```

Then replace values in `Config/secrets.xcconfig` with the values you have received.

After you will need to run the API Generation steps below.

## Install Docker (Mozillans/Pocketeers Only)

To run our UITests locally, you will need an instance of [Snowplow Micro](https://github.com/snowplow-incubator/snowplow-micro) running on your system on port 9090.
We use Docker for this purpose. You can install Docker using Homebrew: `brew install docker`
Or you may download it from the [Docker website](https://docs.docker.com/desktop/install/mac-install/)

Once installed you need to provide your Docker username to the iOS lead so they can add you to the Pocket docker Organisation.
Once done you can simply run `docker compose up` in Terminal from the root Pocket directory to run an instance of Snowplow Micro.

###Snowplow Micro
Snowplow micro has 4 endpoints of note:
1. http://localhost:9090/micro/all - Lists the total number of events received and whether they are bad or good.
2. http://localhost:9090/micro/good - Returns all the good (passed validation) events snowplow received and the data within.
3. http://localhost:9090/micro/bad - Returns all the bad (failed validation) events snowplow received and the reason why.
3. http://localhost:9090/micro/reset - Resets snowplow to 0 events received. Should be ran at the start of each test.

[SnowplowMicro](./Tests iOS/Support/SnowplowMicro) class is used to interact with Snowplow and provide helper assertions to make testing events easier.


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

To modify/create a request look into `PocketKit/Sources/PocketGraph/user-defined-operations`

Any modifications done here and after you generate above will be auto-generated in our codebase for usage.

Previously we used a singleton `PocketSource`, but we are moving away from that model and instead encourage the adoption of a protocol Service.  As an example, you can look at `SlateService`.

### Future

We plan on implementing the following changes in the future:

- Ensure that the [`PocketKit/Sources/PocketGraph/schema.graphqls`](./PocketKit/Sources/PocketGraph/schema.graphqls) and [`PocketKit/Sources/PocketGraph/`](./PocketKit/Sources/PocketGraph/) are generated on demand at build time.
  - Blocked by needing [Swift Build Tool support in Apollo](https://github.com/apollographql/apollo-ios/pull/2464)

## Setup Fonts

Pocket uses custom fonts: Graphik & Blanco. In order for the styles to present as expected in your local build you need to obtain the font files. Mozillians and Pocketeers can request them from the iOS manager and install them in [`PocketKit/Sources/Textile/Style/Typography/Fonts`](./PocketKit/Sources/Textile/Style/Typography/Fonts)


## Build Targets

### Pocket Kit

PocketKit is the foundation of all of Pocket. Pocket is purposefully abstracted into a Kit so that we can define multiple targets in the Apple Ecosystem and still use the same code base. Here you can find the view controllers, app delegates and most entrypoints into the Pocket application.

### Sync

Sync is the main API & Core Data layer that Pocket is built on. This library provides the work needed to communicate with the Pocket API and our Offline storage layer, backed by CoreData.

### Textile

Textile provides the standard views and styles that can be re-used across all of the Pocket targets we create in the Apple Ecosystem.

### Analytics

Analytics provides Pocket's implementation of [Snowplow](https://github.com/snowplow/) which we use to provide a feedback loop to the Pocket product team into how our features are used.

### SaveToPocketKit

SaveToPocketKit is the code base needed to make the Pocket Share Extension function and is embeded in the SaveToPocket Extension that enables you to Save to Pocket from other applications.

### SharedPocketKit

SharedPocketKit is for code that is shared between PocketKit and SaveToPocketKit. It contains code for session management and keychain storage that is used across all apps in the Pocket App Group.

## Developing in Pocket

See our Contribution Guide for day-to-day Pocket development guides.
> [!NOTE]
> As of now, contribution to Pocket is limited to Mozillians but we are planning to add external contributions to our repo. Stay tuned!

## License Acknowledgements

When you add a dependncy we need to ensure that our [OpenSource Licenses](https://getpocket.com/opensource_licenses_ios) are up to date with all licenses we are using. 

The following are the high level steps to update the notices page:

1. Install [LicensePlist](https://github.com/mono0926/LicensePlist) `brew install licenseplist`
2. Run `license-plist --markdown-path Acknowledgements.markdown`
3. Open an issue on [Bedrock](https://github.com/mozilla/bedrock/) with a description and the requested page to update with a link to a document of the generated `Acknowledgements.markdown`
