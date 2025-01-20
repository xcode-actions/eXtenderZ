/*
Copyright 2019 happn
Copyright 2024 François Lamboley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import XCTest
@testable import eXtenderZ



class eXtenderZTests : XCTestCase {
	
	override func setUp() {
		witnesses = [:]
	}
	
	func testNothingGainCoverage() {
		_eXtenderZ_heyTheresARealSymbolInThisLib_()
		XCTAssertTrue(true)
	}
	
	func testBasicExtender() {
		assert(witnesses.count == 0)
		
		let extender = SimpleObject0Extender()
		let object = XTZSimpleObject0()
		
		object.doTest1()
		XCTAssertEqual(witnesses, ["test1": 1])
		
		XCTAssertTrue(object.xtz_add(extender))
		object.doTest1()
		XCTAssertEqual(witnesses, ["test1": 2, "XTZSimpleObject0Helptender-test1": 1, "SimpleObject0Extender-test1": 1])
		
		XCTAssertTrue(object.xtz_remove(extender))
		object.doTest1()
		XCTAssertEqual(witnesses, ["test1": 3, "XTZSimpleObject0Helptender-test1": 1, "SimpleObject0Extender-test1": 1])
	}
	
	func testOneShotExtender() {
		let extender = OneShotObject0Extender()
		let object = XTZSimpleObject0()
		
		XTZCheckedAddExtenderIfNoneFromSameClass(object, extender)
		XTZCheckedAddExtenderIfNoneFromSameClass(object, extender)
		XCTAssertEqual(object.xtz_extenders().count(where: { $0 is OneShotObject0Extender }), 1)
	}
	
}
