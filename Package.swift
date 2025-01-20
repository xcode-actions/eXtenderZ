// swift-tools-version:5.3
import PackageDescription


/* Binary package definition for eXtenderZ.
 * Use the xcodeproj if you want to work on the eXtenderZ project. */

let package = Package(
	name: "eXtenderZ",
	products: [
		/* Sadly the line below does not work.
		 * The idea was to have a library where SPM chooses whether to take the dynamic or static version of the target, but it fails (Xcode 12B5044c). */
//		.library(name: "eXtenderZ", targets: ["eXtenderZ-static", "eXtenderZ-dynamic"]),
		.library(name: "eXtenderZ-static", targets: ["eXtenderZ-static"]),
		.library(name: "eXtenderZ-dynamic", targets: ["eXtenderZ-dynamic"])
	],
	targets: [
		.binaryTarget(name: "eXtenderZ-static", url: "https://github.com/Frizlab/eXtenderZ/releases/download/2.1.0/eXtenderZ-static.xcframework.zip", checksum: "315ee17ab27d202b18773b40fdb009ab81756e5d71ac418e8493f5ededab5c4d"),
		.binaryTarget(name: "eXtenderZ-dynamic", url: "https://github.com/Frizlab/eXtenderZ/releases/download/2.1.0/eXtenderZ-dynamic.xcframework.zip", checksum: "9fe77228aba4c3ab70953a110201c32766ed2b87fa7bf2f6a90fc103bbb4fc72")
	]
)
