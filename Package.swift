// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MacFaceKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "MacFaceKit", targets: ["MacFaceKit"])],
    targets: [.target(name: "MacFaceKit")]
)
