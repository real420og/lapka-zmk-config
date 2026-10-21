// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LapkaBattery",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "LapkaBattery", targets: ["LapkaBattery"])],
    targets: [
        .executableTarget(name: "LapkaBattery"),
        .testTarget(name: "LapkaBatteryTests", dependencies: ["LapkaBattery"]),
    ]
)
