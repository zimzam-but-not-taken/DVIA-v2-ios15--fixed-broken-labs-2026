# DVIA-v2 — iOS 15+ fixes

[DVIA-v2](https://github.com/prateek147/DVIA-v2) by @prateekg147, repaired so the challenges actually work on current iOS and build with current Xcode. Nothing is hardened: every vulnerability is still there to be found and exploited.

**Tested on:** iPhone 7, iOS 15.8.4, Dopamine (rootless). Built with Xcode 27 / iOS 27 SDK.

Fixes were made with the help of Claude Fable 5.1 (Anthropic) in Claude Code, reviewed and tested on-device by the maintainer.

## Install

`DVIA-v2.ipa` at the repo root is an **unsigned** arm64 build, minimum iOS 15.0.

* Jailbroken device: AppSync Unified + Filza or `ipainstaller`, or TrollStore.
* Non-jailbroken device: sign it yourself with Sideloadly, AltStore or Apple Configurator.

## Build

1. Clone, then open `DVIA-v2/DVIA-v2.xcworkspace` in Xcode 15 or newer.
2. `Pods/` is checked in. Run `pod install` only if you change the `Podfile`.
3. Set your own team under Signing and run on a device.

Notes:

* Deployment target is **iOS 15.0** for the app and every pod. Xcode 26+ refuses anything lower.
* Pods: RealmSwift 4.1.1, couchbase-lite-ios 1.4.4, Flurry 12.1.4. Parse, Google Analytics and Bolts were unused and are gone.
* Simulator builds exclude arm64 because the pinned Realm/Couchbase binaries predate Apple Silicon. Use a device.
* `DVIA-v2/update-pins.sh` regenerates the certificate pins for the Network Layer Security lab if example.com changes CA.

## What was fixed

| Challenge | What was wrong | What changed |
|---|---|---|
| Local Data Storage → Realm | Model used plain Swift optionals; Realm persisted an empty schema | Properties are `@objc dynamic`; data lands in `Documents/default.realm` |
| Local Data Storage → Webkit Caching | Screen was empty, nothing was ever cached | Login form; request/response cached to `Library/Caches/<bundle>/Cache.db` (`cfurl_cache_*` tables) and `Library/Caches/WebKit` |
| Jailbreak Detection (all 5 tests) | Only rootful 2017 paths; `canOpenURL` always false | Same three vectors (file paths, sandbox write, `canOpenURL`) with rootless `/var/jb`, Sileo/Zebra and ElleKit paths added; `LSApplicationQueriesSchemes` added. Bypass methods unchanged (hook / swizzle / patch) |
| Anti Anti Hooking | Only looked for MobileSubstrate/cycript | Also ElleKit, libhooker, substitute (the modern Substrate equivalents). Frida is deliberately not on the list |
| Side Channel → Device Logs | Crashed: Parse SDK was never initialised | Logs via `print`, `NSLog`, `os_log` |
| IPC Issues | `dvia://` handler crashed on URLs without the call path | Guarded; still no caller validation |
| Webview Issues | `UIWebView` | `WKWebView`, same XSS |
| Network Layer Security | Pinned cert from 2018; example.com now rotates an ECDSA leaf behind Cloudflare | Pins the issuing CA chain (valid to 2035) |
| Data Leakage to Third Parties | Crashed on phone numbers with spaces | Safe URL building; still leaks to Flurry and over plain HTTP |
| Runtime Manipulation | Crashed on empty "validate code"; article 2 button opened article 1 | Guarded; fixed link |
| Sensitive Information in Memory | Secret string was never built | Built on screen load, kept alive |
| Excessive Permissions | Camera session started on the main thread | Background queue |
| App-wide | Would not build on Xcode 26+; letterboxed on notch devices | Deployment targets raised to 15.0; `UILaunchScreen` added |

Everything else (Plist, UserDefaults, Keychain, Core Data, Couchbase, YapDatabase, Phishing, Binary Protection, Touch/Face ID, Broken Cryptography, Application Patching, Screenshot, Keystroke Logging, Pasteboard, Cookies) was reviewed and left as is.

## Challenges

1. Local Data Storage
2. Jailbreak Detection
3. Excessive Permissions
4. Runtime Manipulation
5. Anti Anti Hooking/Debugging
6. Binary Protection
7. Touch/Face ID Bypass
8. Phishing
9. Side Channel Data Leakage
10. IPC Issues
11. Broken Cryptography
12. Webview Issues
13. Network Layer Security
14. Application Patching
15. Sensitive Information in Memory
