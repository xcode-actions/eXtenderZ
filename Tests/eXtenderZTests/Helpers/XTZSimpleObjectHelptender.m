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

#import "XTZSimpleObjectHelptender.h"

@import eXtenderZ.HelptenderUtils;



@implementation XTZSimpleObject0Helptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZSimpleObject0Extender)];
}

+ (void)xtz_helptenderHasBeenAdded:(NSObject <XTZHelptender> *)helptender
{
#pragma unused(helptender)
	/* Nothing do to here. */
}

+ (void)xtz_helptenderWillBeRemoved:(NSObject <XTZHelptender> *)helptender
{
#pragma unused(helptender)
	/* Nothing do to here. */
}

- (void)doTest1
{
	witnesses[@"XTZSimpleObject0Helptender-test1"] = @(witnesses[@"XTZSimpleObject0Helptender-test1"].integerValue + 1);
	
	for (id <XTZSimpleObject0Extender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZSimpleObject0Extender)])
		if ([extender respondsToSelector:@selector(didCallTest1)])
			[extender didCallTest1];
	
	((void (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZSimpleObject0Helptender));
}

@end
