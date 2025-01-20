/*
Copyright 2019 happn
Copyright 2025 François Lamboley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import Foundation



class OneShotObject0Extender : NSObject, XTZSimpleObject0Extender {
	
	func prepareObject(forExtender object: NSObject) -> Bool {
		return !object.xtz_isExtended(byClass: OneShotObject0Extender.self)
	}
	
	func prepareObjectForRemoval(ofExtender object: NSObject) {
	}
	
	func didCallTest1() {
		/*nop*/
	}
	
}
