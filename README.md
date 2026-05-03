# HomeDepotCA Webview Fix LSPosed

LSPosed module for `com.thehomedepotca` that bypasses the app's 'unsupported device' screen so the app can continue using the system WebView provider (instead of closing due to `com.google.android.webview` not being the default Webview)

Mainly solves the issue where one would want to use the Home Depot Canada app on a de-Googled Android device that doesn't have `com.google.android.webview`.

## Build locally

Set `ANDROID_SDK_ROOT` and run:

```bash
./build-release.sh
```
