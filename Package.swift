// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ECNKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "ECNKit", targets: ["ECNKit"])],
    targets: [.target(name: "ECNKit")]
)
