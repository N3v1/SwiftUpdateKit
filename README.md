# SwiftUpdateKit 

**A secure, modern software update framework for macOS, written entirely in Swift.**

SwiftUpdateKit is a lightweight alternative to Sparkle, purpose-built for Swift-based macOS applications. It provides a native and extensible approach to managing app updates, with support for signed feeds, automatic installation, custom UI, and flexible integration into existing apps.

> **Looking to distribute macOS app updates without relying on external binaries or Objective-C?**
> SwiftUpdateKit offers a Swift-first, transparent, and fully notarization-compliant solution.

### Requirements

- Swift 6.0 or later
- Xcode 16 or later
- macOS 15 (Sequoia) or later
- HTTPS-hosted update feed
- Signed and notarized application bundle

> [!TIP] **Need to generate update feeds?**
> SwiftUpdateKit includes a built-in command-line tool (`swift-update-gen`) for generating and signing feeds directly from your release artifacts.

## Installation

## Adoption

## Testing

## Design

SwiftUpdateKit is designed for clarity, security, and seamless integration with macOS. Its architecture follows modern Swift conventions and respects platform best practices:

- **Swift-native implementation** — Written entirely in Swift, with no dependencies on the Objective-C runtime.
- **Security-first by design** — Enforces HTTPS, verifies digitally signed update feeds, and performs SHA-256 validation on all assets.
- **Modular architecture** — Integrate only the components your app needs, whether for silent background updates, interactive prompts, or a fully customized interface.
- **Ready for production** — Fully compatible with signed and notarized `.app` and `.pkg` bundles, ensuring smooth deployment with Gatekeeper and system integrity protections.
- **Self-contained** — Requires no third-party installers or scripting; built entirely on Foundation and AppKit.

## Contributing

Contributions are welcome whether it’s fixing a bug, improving documentation, or suggesting new features.

If you’d like to get involved, please see the [CONTRIBUTING.md](./CONTRIBUTING.md) for how to get started.

Not sure where to begin? Check out the [issues](https://github.com/N3v1/SwiftUpdateKit/issues). I’m happy to
collaborate and support contributors of all experience levels.

### Project Status

Version `0.1.0` is the first official release of SwiftUpdateKit. Earlier versions have no source stability guarantees.

Because the SwiftUpdateKit library is under active development, source stability is only guaranteed within minor versions (for example,
between `0.1.1` and `0.1.2`). If you don't want potentially source-breaking package updates, you can specify your package dependency using 
`.upToNextMinorVersion(from: "0.1.0")` instead.

Future minor versions of the package may introduce changes to these rules as needed.

## License

SwiftUpdateKit is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

You may freely use, modify, and distribute this software under the terms of the license. See the [LICENSE](LICENSE) file for full details.

_© 2025 Nevio Hirani and the SwiftUpdateKit contributors._