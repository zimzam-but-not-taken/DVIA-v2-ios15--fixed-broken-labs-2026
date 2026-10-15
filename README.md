# DVIA-v2

Powered by <a href="https://8ksec.io">8ksec.io</a>

DVIA-v2 written in Swift along with additional vulnerabilities

Damn Vulnerable iOS App (DVIA) is an iOS application that is damn vulnerable. Its main goal is to provide a platform to mobile security enthusiasts/professionals or students to test their iOS penetration testing skills in a legal environment. This project is developed and maintained by @prateekg147. The vulnerabilities and solutions covered in this app are tested up to iOS 11. The current version is writen in Swift and has the following vulnerabilities.

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

## Installing DVIA on any iOS device 

The best way to install DVIA from a Mac is using <a href="https://support.apple.com/en-ae/apple-configurator
">Apple Configurator App</a>.
If you are using Windows or Linux, you can use AltStore, Cydia Impactor etc. A paid developer account might be required in some cases.

## Compiling DVIA using Xcode

### Steps

1. Clone the DVIA repo , git clone https://github.com/prateek147/DVIA-v2
2. cd to the project root directory where the <em>Podfile</em> is present (/DVIA-v2/DVIA-v2). Then run <em>pod install</em>
3. Open the <em>DVIA-v2.xcworkspace</em> file with Xcode. You can now directly run the app on a simulator.
4. For running on the device, go under Project settings in Xcode on the top left, head over to the <em>General</em> tab and under <em>Signing</em>, enter credentials for your Apple ID.
5. Now you can build and run the project on the device. You will have to trust the app again by going under Settings -> General -> Device Management. 


## Fork notes: what was fixed (October 2026)

Upstream targets iOS 11-era devices and jailbreaks, and several challenges had silently stopped working on current iOS and would not build with current Xcode. This fork only makes the challenges *work again*; it does not harden them. Every vulnerability is still there to be found and exploited.

**Tested on:** iPhone 7, iOS 15.8.4, Dopamine (rootless) jailbreak. Built with Xcode 27 / iOS 27 SDK.

The fixes in this fork were made with the help of Claude Fable 5.1 (Anthropic) running in Claude Code, reviewed and tested on-device by the fork maintainer.

### Build
* Deployment target raised to **iOS 15.0** for the app and every pod. Xcode 26+ refuses anything lower.
* Unused pods removed (Parse, Google Analytics, Bolts). Remaining: RealmSwift 4.1.1, couchbase-lite-ios 1.4.4, Flurry 12.1.4. `Pods/` is checked in; run `pod install` only if you change the `Podfile`.
* Simulator builds exclude arm64 because the pinned Realm/Couchbase binaries predate Apple Silicon. Use a device.
* `UILaunchScreen` added so the app renders full screen on notch devices.

### Challenges
| Challenge | What was wrong | What changed |
|---|---|---|
| Local Data Storage → Realm | Model used plain Swift optionals; Realm persisted an empty schema | Properties are `@objc dynamic`; data lands in `Documents/default.realm` |
| Local Data Storage → Webkit Caching | Screen was empty, nothing was ever cached | Login form; request/response cached to `Library/Caches/<bundle>/Cache.db` (`cfurl_cache_*` tables) and `Library/Caches/WebKit` |
| Jailbreak Detection (all 5 tests) | Only rootful 2017 paths; `canOpenURL` always false | Same three vectors as upstream (file paths, sandbox write, `canOpenURL`) with rootless `/var/jb`, Sileo/Zebra and ElleKit paths added; `LSApplicationQueriesSchemes` added. Bypass methods are unchanged (hook / swizzle / patch) |
| Anti Anti Hooking | Only looked for MobileSubstrate/cycript | Also ElleKit, libhooker, substitute (the modern Substrate equivalents). Frida is deliberately not on the list |
| Side Channel → Device Logs | Crashed: Parse SDK was never initialised | Logs via `print`, `NSLog`, `os_log` |
| IPC Issues | `dvia://` handler crashed on URLs without the call path | Guarded; still no caller validation |
| Webview Issues | `UIWebView` | `WKWebView`, same XSS |
| Network Layer Security | Pinned cert from 2018; example.com now rotates an ECDSA leaf behind Cloudflare | Pins the issuing CA chain (valid to 2035). `DVIA-v2/update-pins.sh` regenerates pins |
| Data Leakage to Third Parties | Crashed on phone numbers with spaces | Safe URL building; still leaks to Flurry and over plain HTTP |
| Runtime Manipulation | Crashed on empty "validate code"; article 2 button opened article 1 | Guarded; fixed link |
| Sensitive Information in Memory | Secret string was never built | Built on screen load, kept alive |
| Excessive Permissions | Camera session started on the main thread | Background queue |

Everything else (Plist, UserDefaults, Keychain, Core Data, Couchbase, YapDatabase, Phishing, Binary Protection, Touch/Face ID, Broken Cryptography, Application Patching, Screenshot, Keystroke Logging, Pasteboard, Cookies) was reviewed and left as is.

### Installing on a jailbroken device
`DVIA-v2.ipa` at the repo root is an **unsigned** arm64 build. On a jailbroken device install it with AppSync Unified plus Filza or `ipainstaller`, or with TrollStore. For a non-jailbroken device sign it with your own certificate (Sideloadly, AltStore, Apple Configurator).
