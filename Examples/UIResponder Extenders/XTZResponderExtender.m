/*
Copyright 2021 happn
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

#import "XTZResponderExtender.h"

@import eXtenderZ.HelptenderUtils;



@implementation XTZResponderHelptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZResponderExtender)];
}

+ (void)xtz_helptenderHasBeenAdded:(XTZResponderHelptender *)helptender
{
#pragma unused(helptender)
	/* Nothing to do here. */
}

+ (void)xtz_helptenderWillBeRemoved:(XTZResponderHelptender *)helptender
{
#pragma unused(helptender)
	/* Nothing to do here. */
}

/* Removed because we do nothing special here:
- (BOOL)xtz_prepareForExtender:(NSObject <XTZExtender> *)extender
{
	if (!((BOOL (*)(id, SEL, NSObject <XTZExtender> *))HELPTENDER_CALL_SUPER(XTZResponderHelptender, extender))) return NO;
	// nop
	return YES;
}*/

/* Removed because we do nothing special here:
- (void)xtz_removeExtender:(NSObject <XTZExtender> *)extender atIndex:(NSUInteger)idx
{
	// nop
	((void (*)(id, SEL, NSObject <XTZExtender> *, NSUInteger))HELPTENDER_CALL_SUPER(XTZResponderHelptender, extender, idx));
}*/

- (BOOL)canBecomeFirstResponder
{
	for (id <XTZResponderExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZResponderExtender)]) {
		if ([extender respondsToSelector:@selector(responderCanBecomeFirstResponder:)]) {
			TVL flag = [extender responderCanBecomeFirstResponder:self];
			if (flag == TVL_MAYBE) continue;
			return flag;
		}
	}
	
	return ((BOOL (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZResponderHelptender));
}

- (UIView *)inputView
{
	for (id <XTZResponderExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZResponderExtender)])
		if ([extender respondsToSelector:@selector(inputViewForResponder:)])
			return [extender inputViewForResponder:self];
	
	return ((UIView *(*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZResponderHelptender));
}

- (UIView *)inputAccessoryView
{
	for (id <XTZResponderExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZResponderExtender)])
		if ([extender respondsToSelector:@selector(inputAccessoryViewForResponder:)])
			return [extender inputAccessoryViewForResponder:self];
	
	return ((UIView *(*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZResponderHelptender));
}

- (NSString *)textInputContextIdentifier
{
	for (id <XTZResponderExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZResponderExtender)])
		if ([extender respondsToSelector:@selector(textInputContextIdentifierForResponder:)])
			return [extender textInputContextIdentifierForResponder:self];
	
	return ((NSString *(*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZResponderHelptender));
}

@end
