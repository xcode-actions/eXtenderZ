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
		.binaryTarget(name: "eXtenderZ-static", url: "https://github.com/Frizlab/eXtenderZ/releases/download/1.0.9/eXtenderZ-static.xcframework.zip", checksum: "5406b0e9074808a6d06b21fe13a8a8af73bafa0d127beeddb813e1c5d7b4ba4b"),
		.binaryTarget(name: "eXtenderZ-dynamic", url: "https://github.com/Frizlab/eXtenderZ/releases/download/1.0.9/eXtenderZ-dynamic.xcframework.zip", checksum: "204c6d6dd42bbbf26d6ea5436ad19e8d4d66a23b5097990977639b45b132ddcb")
	]
)
