# Pocket iOS

## Building

### secrets.xcconfig

A `secrets.xcconfig` file must be placed in the `Config` directory for the project to build. This file, as the name suggests, contains secrets that are required to build the Pocket app.

This file currently requires one build setting:

```
// secrets.xcconfig
POCKET_API_CONSUMER_KEY=...
```

### Launch Arguments

The `Pocket (iOS)` scheme, by default, supports the following arguments:

- `clearKeychain` 
- `clearUserDefaults`
- `clearFirstLaunch`
- `clearImageCache`
- `clearCoreData`
- `disableSentry`
    - Enabled by default
- `disableSnowplow`
    - Enabled by default

### Environment Variables

The `Pocket (iOS)` scheme, by default, supports the following variables:

- `SNOWPLOW_IDENTIFIER`
    - The app identifier used when tracking events via Snowplow
    - Requirement: append `-dev` to your identifier when working in a development environment
    - By default, set to `pocket-ios-next-dev` when enabled
- `SNOWPLOW_ENDPOINT`
    - The endpoint used when sending Snowplow events
    - By default, set to `http://127.0.0.1:9090` when enabled