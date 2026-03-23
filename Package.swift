// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "cmux",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "cmux", targets: ["cmux"])
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.2.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.1"),
        .package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "9.3.0"),
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.41.0"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.1"),
        .package(path: "vendor/bonsplit")
    ],
    targets: [
        .executableTarget(
            name: "cmux",
            dependencies: [
                "SwiftTerm",
                .product(name: "Sparkle", package: "sparkle"),
                .product(name: "Sentry", package: "sentry-cocoa"),
                .product(name: "PostHog", package: "posthog-ios"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Bonsplit", package: "bonsplit")
            ],
            path: "Sources"
        )
    ]
)
