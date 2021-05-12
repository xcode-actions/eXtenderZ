// swift-tools-version:5.3
import PackageDescription


/* Binary package definition for eXtenderZ.
 * Use the xcodeproj if you want to work on the eXtenderZ project. */

let package = Package(
	name: "eXtenderZ",
	products: [
		/* Sadly the line below does not work. The idea was to have a
		 * library where SPM chooses whether to take the dynamic or static
		 * version of the target, but it fails (Xcode 12B5044c). */
//		.library(name: "eXtenderZ", targets: ["eXtenderZ-static", "eXtenderZ-dynamic"]),
		.library(name: "eXtenderZ-static", targets: ["eXtenderZ-static"]),
		.library(name: "eXtenderZ-dynamic", targets: ["eXtenderZ-dynamic"])
	],
	targets: [
		.binaryTarget(name: "eXtenderZ-static", url: "https://github.com/xcode-actions/eXtenderZ/releases/download/1.0.6/eXtenderZ-static.xcframework.zip", checksum: "f24f9603f8fd4996fce9a744f906d88aeb8fe6707e0e061f5961c5266ce0b346"),
		.binaryTarget(name: "eXtenderZ-dynamic", url: "https://github.com/xcode-actions/eXtenderZ/releases/download/1.0.6/eXtenderZ-dynamic.xcframework.zip", checksum: "d2d98cabd0aea9a9fdb637ee7e7e1d1d9fa14144e4429e093f2866e1697f868a")
	]
)
