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
		.binaryTarget(name: "eXtenderZ-static", url: "https://github.com/Frizlab/eXtenderZ/releases/download/1.0.8/eXtenderZ-static.xcframework.zip", checksum: "e35579f8ba5a450af3c75afd67d610c085cfd53543c4ec3c9c54d858536107d9"),
		.binaryTarget(name: "eXtenderZ-dynamic", url: "https://github.com/Frizlab/eXtenderZ/releases/download/1.0.8/eXtenderZ-dynamic.xcframework.zip", checksum: "06b51842d3e22fc241f50a7a5e09470ae88f4f3fe92fdcd44366173dcfe63086")
	]
)
