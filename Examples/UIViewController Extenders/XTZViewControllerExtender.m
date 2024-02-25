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

#import "XTZViewControllerExtender.h"

@import eXtenderZ.HelptenderUtils;



static char EXTENDERS_DID_LAYOUT_SUBVIEWS_KEY;

@implementation XTZViewControllerHelptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZViewControllerExtender)];
}

+ (void)xtz_helptenderHasBeenAdded:(XTZViewControllerHelptender *)helptender
{
#pragma unused(helptender)
	/* Nothing to do here. */
}

+ (void)xtz_helptenderWillBeRemoved:(XTZViewControllerHelptender *)helptender
{
#pragma unused(helptender)
	objc_setAssociatedObject(helptender, &EXTENDERS_DID_LAYOUT_SUBVIEWS_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersDidLayoutSubviews, EXTENDERS_DID_LAYOUT_SUBVIEWS_KEY)

- (BOOL)xtz_prepareForExtender:(NSObject <XTZExtender> *)extender
{
	if (!((BOOL (*)(id, SEL, NSObject <XTZExtender> *))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, extender))) return NO;
	
	if ([extender conformsToProtocol:@protocol(XTZViewControllerExtender)] &&
		 [extender respondsToSelector:@selector(viewControllerViewDidLayoutSubviews:)])
		[[self xtz_extendersDidLayoutSubviewsCreateIfNotExist:YES] addObject:extender];
	
	return YES;
}

- (void)xtz_removeExtender:(NSObject <XTZExtender> *)extender atIndex:(NSUInteger)idx
{
	[self.xtz_extendersDidLayoutSubviews removeObjectIdenticalTo:extender];
	
	((void (*)(id, SEL, NSObject <XTZExtender> *, NSUInteger))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, extender, idx));
}

- (void)viewDidLoad
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewControllerViewDidLoad:)])
			[extender viewControllerViewDidLoad:self];
	
	((void (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZViewControllerHelptender));
#ifdef __clang_analyzer__
	[super viewDidLoad];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:viewWillAppear:)])
			[extender viewController:self viewWillAppear:animated];
	
	((void (*)(id, SEL, BOOL))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, animated));
#ifdef __clang_analyzer__
	[super viewWillAppear:animated];
#endif
}

- (void)viewDidLayoutSubviews
{
	for (id <XTZViewControllerExtender> extender in self.xtz_extendersDidLayoutSubviews)
		[extender viewControllerViewDidLayoutSubviews:self];
	
	((void (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZViewControllerHelptender));
}

- (void)viewDidAppear:(BOOL)animated
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:viewDidAppear:)])
			[extender viewController:self viewDidAppear:animated];
	
	((void (*)(id, SEL, BOOL))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, animated));
#ifdef __clang_analyzer__
	[super viewDidAppear:animated];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:viewWillDisappear:)])
			[extender viewController:self viewWillDisappear:animated];
	
	((void (*)(id, SEL, BOOL))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, animated));
#ifdef __clang_analyzer__
	[super viewWillDisappear:animated];
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:viewDidDisappear:)])
			[extender viewController:self viewDidDisappear:animated];
	
	((void (*)(id, SEL, BOOL))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, animated));
#ifdef __clang_analyzer__
	[super viewDidDisappear:animated];
#endif
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:prepareForSegue:sender:)])
			[extender viewController:self prepareForSegue:segue sender:sender];
	
	((void (*)(id, SEL, UIStoryboardSegue *, id))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, segue, sender));
#ifdef __clang_analyzer__
	[super prepareForSegue:segue sender:sender];
#endif
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:didMoveToParentViewController:)])
			[extender viewController:self didMoveToParentViewController:parent];
	
	((void (*)(id, SEL, UIViewController *))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, parent));
#ifdef __clang_analyzer__
	[super didMoveToParentViewController:parent];
#endif
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewControllerPreferredStatusBarStyle:)])
			return [extender viewControllerPreferredStatusBarStyle:self];
	
	return ((UIStatusBarStyle (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZViewControllerHelptender));
#ifdef __clang_analyzer__
	return [super preferredStatusBarStyle];
#endif
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	for (id <XTZViewControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZViewControllerExtender)])
		if ([extender respondsToSelector:@selector(viewController:willMoveToParentViewController:)])
			[extender viewController:self willMoveToParentViewController:parent];
	
	((void (*)(id, SEL, UIViewController *))XTZ_HELPTENDER_CALL_SUPER(XTZViewControllerHelptender, parent));
#ifdef __clang_analyzer__
	[super willMoveToParentViewController:parent];
#endif
}

@end
