#!/usr/bin/env -S swift-sh --
import Foundation

import ArgumentParser    /* @apple/swift-argument-parser            ~> 1.2.0 */
import CLTLogger         /* @xcode-actions/clt-logger               ~> 0.8.0 */
import Logging           /* @apple/swift-log                        ~> 1.4.2 */
import ProcessInvocation /* @xcode-actions/swift-process-invocation ~> 1.0.0 */
import UnwrapOrThrow     /* @Frizlab                                ~> 1.0.1 */



/* Let’s bootstrap the logger before anything else. */
LoggingSystem.bootstrap{ _ in CLTLogger() }
let logger: Logger = {
	var ret = Logger(label: "main")
	ret.logLevel = .debug
	return ret
}()


_ = await Task{ await CreateXcframeworks.main() }.value
struct CreateXcframeworks : AsyncParsableCommand {
	
	@Argument(help: "If version is set, the generated Package.swift file will contain the path to the GitHub release. Should be used by CI pipelines only.")
	var version: String?
	
	func run() async throws {
		let filepath = CommandLine.arguments.first ?? ""
		FileManager.default.changeCurrentDirectoryPath(URL(fileURLWithPath: filepath).deletingLastPathComponent().deletingLastPathComponent().path)
		
		let buildFolderURL = URL(fileURLWithPath: "./build", isDirectory: true)
		let archivesFolderURL = buildFolderURL.appendingPathComponent("archives")
		let types = [
			(name: "static",  xcframeworkArgs: { (_ archiveURL: URL) -> [String] in [
				"-library", "\(archiveURL.appendingPathComponent("Products").appendingPathComponent("usr").appendingPathComponent("local").appendingPathComponent("lib").appendingPathComponent("libeXtenderZ.a").absoluteURL.path)",
				"-headers", "\(archiveURL.appendingPathComponent("Products").appendingPathComponent("usr").appendingPathComponent("local").appendingPathComponent("include").absoluteURL.path)"
			] }),
			
			(name: "dynamic", xcframeworkArgs: { (_ archiveURL: URL) -> [String] in [
				"-framework", "\(archiveURL.appendingPathComponent("Products").appendingPathComponent("Library").appendingPathComponent("Frameworks").appendingPathComponent("eXtenderZ.framework").absoluteURL.path)",
				"-debug-symbols", "\(archiveURL.appendingPathComponent("dSYMs").appendingPathComponent("eXtenderZ.framework.dSYM").absoluteURL.path)"
			] })
		]
		
		/* Hints:
		 *   - <https://mokacoding.com/blog/xcodebuild-destination-options/>
		 *   - xcodebuild -scheme eXtenderZ-dynamic-iOS -showdestinations */
		let targets = [
			(sdk: "macOS", platform: "macOS"),
			(sdk: "visionOS", platform: "visionOS"),
			(sdk: "visionOS", platform: "visionOS Simulator"),
			(sdk: "iOS", platform: "iOS"),
			(sdk: "iOS", platform: "iOS Simulator"),
			(sdk: "iOS", platform: "macOS"),
			(sdk: "tvOS", platform: "tvOS"),
			(sdk: "tvOS", platform: "tvOS Simulator"),
			(sdk: "watchOS", platform: "watchOS"),
			(sdk: "watchOS", platform: "watchOS Simulator")
		]
		
		try writePackageFile(version: version, checksums: Dictionary(uniqueKeysWithValues: types.map{ ($0.name, nil) }))
		
		var checksums = [String: String]()
		for type in types {
			var xcframeworkArgs = ["-create-xcframework"]
			for target in targets {
				let archiveURL = archivesFolderURL.appendingPathComponent("eXtenderZ-\(type.name)-\(target.sdk)-\(target.platform).xcarchive")
				_ = try await ProcessInvocation(
					"xcodebuild", "archive",
					"-project", "eXtenderZ.xcodeproj",
					"-scheme", "eXtenderZ-\(type.name)-\(target.sdk)",
					"-destination", "generic/platform=\(target.platform)",
					"-archivePath", "\(archiveURL.absoluteURL.path)",
					"SKIP_INSTALL=NO", "BUILD_LIBRARY_FOR_DISTRIBUTION=YES",
					stdoutRedirect: .none, stderrRedirect: .none
				).invokeAndGetRawOutput()
				xcframeworkArgs.append(contentsOf: type.xcframeworkArgs(archiveURL))
			}
			
			let xcframeworkURL = buildFolderURL.appendingPathComponent("eXtenderZ-\(type.name).xcframework")
			let zipXCFrameworkURL = xcframeworkURL.appendingPathExtension("zip")
			xcframeworkArgs.append(contentsOf: ["-output", xcframeworkURL.absoluteURL.path])
			_ = try await ProcessInvocation("xcodebuild", args: xcframeworkArgs, stdoutRedirect: .none, stderrRedirect: .none).invokeAndGetRawOutput()
			
			if version != nil {
				_ = try await ProcessInvocation(
					"zip", "-r", zipXCFrameworkURL.absoluteURL.path, xcframeworkURL.lastPathComponent,
					workingDirectory: zipXCFrameworkURL.absoluteURL.deletingLastPathComponent(),
					stdoutRedirect: .none, stderrRedirect: .none
				).invokeAndGetRawOutput()
				
				checksums[type.name] = try await ProcessInvocation("swift", "package", "compute-checksum", zipXCFrameworkURL.absoluteURL.path, stderrRedirect: .none)
					.invokeAndGetStdout().first ?! SimpleError("No output from swift package compute-checksum.")
			}
		}
		if let version = version {
			try writePackageFile(version: version, checksums: checksums)
		}
	}
	
	func writePackageFile(version: String?, checksums: [String: String?]) throws {
		let types = checksums.keys.sorted(by: { $0.count < $1.count })
		
		var packageString = """
			// swift-tools-version:5.3
			import PackageDescription
			
			
			/* Binary package definition for eXtenderZ.
			 * Use the xcodeproj if you want to work on the eXtenderZ project. */
			
			let package = Package(
				name: "eXtenderZ",
				products: [
					/* Sadly the line below does not work.
					 * The idea was to have a library where SPM chooses whether to take the dynamic or static version of the target, but it fails (Xcode 12B5044c). */
			//		.library(name: "eXtenderZ", targets: [
			"""
		
		packageString.append(types.map{ #""eXtenderZ-\#($0)""# }.joined(separator: ", ") + "]),\n")
		packageString.append(types.map{ #"\#t\#t.library(name: "eXtenderZ-\#($0)", targets: ["eXtenderZ-\#($0)"])"# }.joined(separator: ",\n") + "\n")
		packageString.append("""
				],
				targets: [
			
			""")
		packageString.append(types.map{ type in
			let checksum = checksums[type]!
			if let checksum = checksum {
				return #"\#t\#t.binaryTarget(name: "eXtenderZ-\#(type)", url: "https://github.com/Frizlab/eXtenderZ/releases/download/\#(version!)/eXtenderZ-\#(type).xcframework.zip", checksum: "\#(checksum)")"#
			} else {
				return #"\#t\#t.binaryTarget(name: "eXtenderZ-\#(type)", path: "./build/eXtenderZ-\#(type).xcframework")"#
			}
		}.joined(separator: ",\n") + "\n")
		packageString.append("""
				]
			)
			
			""")
		try Data(packageString.utf8).write(to: URL(fileURLWithPath: "Package.swift"))
	}
	
}


struct SimpleError : Error {
	var message: String
	init(_ msg: String) {self.message = msg}
}
