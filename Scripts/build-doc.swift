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
	
	static var configuration = CommandConfiguration(
		abstract: "Build the documentation of eXtenderZ",
		discussion: "Takes a version (git commit-ish) from which to build the documentation, then commit the built documentation in the “documentation” branch."
	)
	
	@Flag
	var push = false
	
	@Argument(help: "The version from which to build the documentation.")
	var version: String
	
	func run() async throws {
		let fm = FileManager.default
		let filepath = CommandLine.arguments.first ?? ""
		fm.changeCurrentDirectoryPath(URL(fileURLWithPath: filepath).deletingLastPathComponent().deletingLastPathComponent().path)
		
		let workdir = fm.temporaryDirectory.appending(component: "eXtenderZ-docbuild-workdir-\(UUID().uuidString)", directoryHint: .isDirectory)
		let buildDir = fm.temporaryDirectory.appending(component: "eXtenderZ-docbuild-builddir-\(UUID().uuidString)", directoryHint: .isDirectory)
		
		/* Create the worktree in which we’ll work. */
		_ = try await ProcessInvocation("git", "worktree", "add", workdir.path(percentEncoded: false), version, stdoutRedirect: .none, stderrRedirect: .none)
			.invokeAndGetRawOutput()
		defer {
			/* We cannot use await in a defer block, so we do the synchronous version of the invocation… */
			try? ProcessInvocation("git", "worktree", "remove", "--force", workdir.path(percentEncoded: false), stdoutRedirect: .none, stderrRedirect: .none)
				.invoke{ _, _, _ in }.1.wait()
		}
		
		/* Build the documentation. */
		_ = try await ProcessInvocation("xcodebuild", "docbuild", "-scheme", "eXtenderZ-docWorkaround", "-derivedDataPath", buildDir.path(percentEncoded: false), "DOCC_HOSTING_BASE_PATH=/eXtenderZ", stdoutRedirect: .none, stderrRedirect: .none)
			.invokeAndGetRawOutput()
		defer {
			try? fm.removeItem(at: buildDir)
		}
		
		/* Checking out the documentation branch. */
		_ = try await ProcessInvocation("git", "-C", workdir.path(percentEncoded: false), "checkout", "documentation", stdoutRedirect: .none, stderrRedirect: .none)
			.invokeAndGetRawOutput()
		
		/* Copy the documentation in the git repo. */
		_ = try await ProcessInvocation(
			"rsync", "-avhXA", "--delete", "--exclude", "/.git", "--exclude", "/.github/", "--exclude", "/.nojekyll",
			buildDir.appending(components: "Build", "Products", "Debug", "eXtenderZ.doccarchive", directoryHint: .isDirectory).path(percentEncoded: false),
			workdir.path(percentEncoded: false),
			stdoutRedirect: .none, stderrRedirect: .none
		).invokeAndGetRawOutput()
		
		_ = try await ProcessInvocation("git", "-C", workdir.path(percentEncoded: false), "add", ".", stdoutRedirect: .none, stderrRedirect: .none).invokeAndGetRawOutput()
		_ = try await ProcessInvocation("git", "-C", workdir.path(percentEncoded: false), "commit", "--allow-empty-message", "-m", "Documentation for version \(version)", stdoutRedirect: .none, stderrRedirect: .none).invokeAndGetRawOutput()
		if push {
			_ = try await ProcessInvocation("git", "-C", workdir.path(percentEncoded: false), "push", stdoutRedirect: .none, stderrRedirect: .none).invokeAndGetRawOutput()
		}
	}
	
}


struct SimpleError : Error {
	var message: String
	init(_ msg: String) {self.message = msg}
}
