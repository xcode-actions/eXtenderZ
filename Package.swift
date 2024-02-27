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
		.binaryTarget(name: "eXtenderZ-static", url: "https://github.com/Frizlab/eXtenderZ/releases/download/2.0.0/eXtenderZ-static.xcframework.zip", checksum: "35ed7b9325e020a387fc1427af2482201481e2078179cc618576385f72a070c5"),
		.binaryTarget(name: "eXtenderZ-dynamic", url: "https://github.com/Frizlab/eXtenderZ/releases/download/2.0.0/eXtenderZ-dynamic.xcframework.zip", checksum: "b34256c27cd80b5170afcc4f9f913f4d6330a888c4b421d0a895fd1b82b923d8")
	]
)
