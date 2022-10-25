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

## Pocket Graph (API) Schema

Pocket for iOS uses Apollo client to autogenerate its API schema code. You will need to run the following commands every time the APIs you use change or if you change your API queries.

### Downloading Graph Schema

To download a new version of [`PocketKit/Sources/Sync/schema.graphqls`](./PocketKit/Sources/Sync/schema.graphqls) you can run the following commands:

```bash
cd PocketKit/
swift package --disable-sandbox --allow-writing-to-package-directory apollo-fetch-schema
```

### Generating API.swift

To download a new version of [`PocketKit/Sources/Sync/API.swift`](./PocketKit/Sources/Sync/API.swift) you can run the following commands:

```bash
cd PocketKit/
swift package --disable-sandbox --allow-writing-to-package-directory apollo-generate
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
