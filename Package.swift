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
		.binaryTarget(name: "eXtenderZ-static", url: "https://github.com/xcode-actions/eXtenderZ/releases/download/1.0.7/eXtenderZ-static.xcframework.zip", checksum: "4dc54bc0fed2b057b0f80d4d950d4146627f59b537a78f908f7d8c2ca8884d6b"),
		.binaryTarget(name: "eXtenderZ-dynamic", url: "https://github.com/xcode-actions/eXtenderZ/releases/download/1.0.7/eXtenderZ-dynamic.xcframework.zip", checksum: "b1c820a25ae3fd2ff5cd370fa34904317a0591344394a193fe73a9194847d5d4")
	]
)
