
<img width="640" alt="suk-github-banner" src="https://github.com/user-attachments/assets/1df43ee3-e749-4d47-858c-2dbbb1bae1d8" />

# Swift Update Kit (SUK)

SUK is a lightweight, customizable, and powerful framework designed to handle software updates effortlessly. It prioritizes simplicity in setup while offering advanced capabilities like delta updates, custom release providers, lifecycle hooks, and more. SUK is ideal for developers seeking an alternative to more intensive frameworks like Sparkle.

> [!NOTE]
> SwiftUpdateKit is currently in development and not yet ready for production use. You are welcome to use the [latest alpha/dev build](https://github.com/N3v1/SwiftUpdateKit/releases/latest) at your own risk. We welcome feedback [here](https://github.com/N3v1/SwiftUpdateKit/issues).

### Features

- **Automatic Update Checks:** Fetch and parse release feeds with minimal setup.
- **Customizable Channels:** Support for stable, beta, alpha, and custom release channels.
- **Delta Updates:** Download only the parts of the software that have changed.
- **Lifecycle Hooks:** Add custom logic during update events (e.g., pre-installation, post-installation).
- **Error Reporting:** Built-in API to handle and report errors gracefully.
- **Code-Signing Validation:** Ensure the integrity and authenticity of updates.
- **Custom Release Providers:** Integrate with GitHub, custom servers, or other release feeds.
- **User-Friendly Update Notifications:** Notify users about updates in a clear, non-intrusive way.

## Getting Started

### System Requirements

- macOS: 15.0 or later
- Swift: 6.0 or later

> [!TIP]
> Legacy Version is in planning

### Installation

#### Swift Package Manager (recommended)
You can install `SwiftUpdateKit` into your Xcode project via SPM. To learn more about SPM, click [here](https://swift.org/package-manager/)

1. In Xcode 12, open your project and navigate to File → Swift Packages → Add Package Dependency...

For Xcode 13, navigate to **Files → Add Package**
1. Paste the repository URL (https://github.com/N3v1/SwiftUpdateKit.git) and click Next.
2. For Version, verify it's **Up to next major**.
3. Click Next and select the SwiftUpdateKit Product
4. Click Finish
5. You are all set, thank you for using SwiftUpdateKit!

You can also add it to the dependencies of your `Package.swift` file:
```swift
dependencies: [
  .package(url: "https://github.com/N3v1/SwiftUpdateKit", .upToNextMajor(from: "1.0.0"))
]
```

## 🚀 Quickstart
> Before you start, please star ⭐️ this repository. Your star is our biggest motivation to pull all-nighters and maintain this open-source project. If you like the idea behind this project, please share it with your friends, colleagues, or anyone who might find it valuable.


## Usage

## Advanced Configuration

## 💪 Contribute

Contributions are welcome here for coders and non-coders alike. No matter what your skill level is, you can for certain contribute to SwiftUpdateKit's open source community. Please read Contributing.md and the step-by-setp guide before starting.

If you encounter ANY issue, have ANY concerns, or ANY comments, please do NOT hesitate to let us know. Open a discussion, issue, or [email us](scribblelabapp.dev@gmail.com). As a developer, we feel you when you don't understand something in the codebase. We try to comment and document as best as we can, but if you happen to encounter any issues, we will be happy to assist in any way we can.

## Contributors
We would like to express our gratitude to all the individuals who have already contributed to SwiftUpdateKit! If you have any SwiftUpdateKit-related projects, documentations, tools or templates, please feel free to contribute it by submitting a pull request to our curated list on GitHub.

## Support Us
Your support is valuable to us and helps us dedicate more time to enhancing and maintaining this repository. Here's how you can contribute:

⭐️ Leave a Star: If you find this repository useful or interesting, please consider leaving a star on GitHub. Your stars help us gain visibility and encourage others in the community to discover and benefit from this work.

📲 Share with Friends: If you like the idea behind this project, please share it with your friends, colleagues, or anyone who might find it valuable.

## License

SUK is licensed under the ScribbleLab License v1.0. See the [LICENSE](LICENSE.md) file for details.
