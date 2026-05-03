# HomeDepotCA Webview Fix LSPosed

LSPosed module for `com.thehomedepotca` that bypasses the app's unsupported-device screen so the app can continue using the system WebView provider.

## Build locally

Set `ANDROID_SDK_ROOT` and run:

```bash
./build-release.sh
```

If you also set `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, and `KEY_ALIAS`, the script signs `hd-webview-spoof/HDWebViewSpoof.apk`. Otherwise it copies the aligned unsigned APK to that path.

## GitHub release flow

The workflow at `.github/workflows/release.yml` can publish a release in either of these ways:

1. Push a tag like `v0.1.0`
2. Run the workflow manually and provide a tag like `v0.1.0`

Each release uploads `hd-webview-spoof/HDWebViewSpoof.apk` as the release asset.
