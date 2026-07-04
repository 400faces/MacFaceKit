// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FacesKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "FacesKit", targets: ["FacesKit"])],
    targets: [.target(name: "FacesKit")]
)
