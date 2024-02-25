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

#import "XTZViewExtender.h"

@import eXtenderZ.HelptenderUtils;



static char EXTENDERS_FRAME_CHANGE_KEY;

@implementation XTZViewHelptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZViewExtender)];
}

+ (void)xtz_helptenderHasBeenAdded:(XTZViewHelptender *)helptender
{
#pragma unused(helptender)
	/* Nothing to do here */
}

+ (void)xtz_helptenderWillBeRemoved:(XTZViewHelptender *)helptender
{
	objc_setAssociatedObject(helptender, &EXTENDERS_FRAME_CHANGE_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersFrameChange, EXTENDERS_FRAME_CHANGE_KEY)

- (BOOL)xtz_prepareForExtender:(NSObject <XTZExtender> *)extender
{
	if (!((BOOL (*)(id, SEL, NSObject <XTZExtender> *))XTZ_HELPTENDER_CALL_SUPER(XTZViewHelptender, extender))) return NO;
	
	if ([extender conformsToProtocol:@protocol(XTZViewExtender)] &&
		 [extender respondsToSelector:@selector(viewDidChangeFrame:originalFrame:)])
		[[self xtz_extendersFrameChangeCreateIfNotExist:YES] addObject:extender];
	
	return YES;
}

- (void)xtz_removeExtender:(NSObject <XTZExtender> *)extender atIndex:(NSUInteger)idx
{
	[self.xtz_extendersFrameChange removeObjectIdenticalTo:extender];
	
	((void (*)(id, SEL, NSObject <XTZExtender> *, NSUInteger))XTZ_HELPTENDER_CALL_SUPER(XTZViewHelptender, extender, idx));
}

- (void)setFrame:(CGRect)frame
{
	CGRect ori = self.frame;
	
	((void (*)(id, SEL, CGRect))XTZ_HELPTENDER_CALL_SUPER(XTZViewHelptender, frame));
	
	for (id <XTZViewExtender> extender in self.xtz_extendersFrameChange)
		[extender viewDidChangeFrame:self originalFrame:ori];
}

- (void)setCenter:(CGPoint)center
{
	CGRect ori = self.frame;
	
	((void (*)(id, SEL, CGPoint))XTZ_HELPTENDER_CALL_SUPER(XTZViewHelptender, center));
	
	for (id <XTZViewExtender> extender in self.xtz_extendersFrameChange)
		[extender viewDidChangeFrame:self originalFrame:ori];
}

- (void)layoutSubviews
{
	CGRect ori = self.frame;
	
	((void (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZViewHelptender));
	
	for (id <XTZViewExtender> extender in self.xtz_extendersFrameChange)
		[extender viewDidChangeFrame:self originalFrame:ori];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	((void (*)(id, SEL, CALayer *))XTZ_HELPTENDER_CALL_SUPER(XTZViewHelptender, layer));
	
	for (id <XTZViewExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewExtender)])
		if ([extender respondsToSelector:@selector(view:layoutSublayersOfLayer:)])
			[extender view:self layoutSublayersOfLayer:layer];
}

@end
