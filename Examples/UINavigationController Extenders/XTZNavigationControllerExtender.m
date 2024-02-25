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

#import "XTZNavigationControllerExtender.h"

@import ObjectiveC.runtime;

@import eXtenderZ.HelptenderUtils;



static char CHEAT_DELEGATE;

@implementation XTZNavigationControllerHelptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZNavigationControllerExtender)];
}

+ (void)xtz_helptenderHasBeenAdded:(XTZNavigationControllerHelptender *)helptender
{
	[helptender xtz_overrideDelegate];
}

+ (void)xtz_helptenderWillBeRemoved:(XTZNavigationControllerHelptender *)helptender
{
	[helptender xtz_resetDelegate];
	objc_setAssociatedObject(helptender, &CHEAT_DELEGATE, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)xtz_prepareForExtender:(NSObject <XTZExtender> *)extender
{
	if (!((BOOL (*)(id, SEL, NSObject <XTZExtender> *))XTZ_HELPTENDER_CALL_SUPER(XTZNavigationControllerHelptender, extender))) return NO;
	
	if ([extender conformsToProtocol:@protocol(XTZNavigationControllerExtender)]) {
		[self xtz_refreshDelegate];
	}
	
	return YES;
}

- (void)xtz_removeExtender:(NSObject <XTZExtender> *)extender atIndex:(NSUInteger)idx
{
	if ([extender conformsToProtocol:@protocol(XTZNavigationControllerExtender)]) {
		[self xtz_refreshDelegate];
	}
	
	((void (*)(id, SEL, NSObject <XTZExtender> *, NSUInteger))XTZ_HELPTENDER_CALL_SUPER(XTZNavigationControllerHelptender, extender, idx));
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
	UIViewController *ret = ((UIViewController *(*)(id, SEL, BOOL))XTZ_HELPTENDER_CALL_SUPER(XTZNavigationControllerHelptender, animated));
	
	for (id <XTZNavigationControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZNavigationControllerExtender)])
		if ([extender respondsToSelector:@selector(navigationController:didPopViewController:animated:)])
			[extender navigationController:self didPopViewController:ret animated:animated];
	
	return ret;
#ifdef __clang_analyzer__
	return [super popViewControllerAnimated:animated];
#endif
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	((void (*)(id, SEL, UIViewController *, BOOL))XTZ_HELPTENDER_CALL_SUPER(XTZNavigationControllerHelptender, viewController, animated));
	
	for (id <XTZNavigationControllerExtender> extender in [self xtz_extendersConformingToProtocol:@protocol(XTZNavigationControllerExtender)])
		if ([extender respondsToSelector:@selector(navigationController:didPushViewController:animated:)])
			[extender navigationController:self didPushViewController:viewController animated:animated];
	
#ifdef __clang_analyzer__
	[super pushViewController:viewController animated:animated];
#endif
}

#pragma mark - Delegate Overriding

- (XTZNavigationControllerDelegateForHelptender *)xtz_cheatDelegateCreateIfNotExist
{
	XTZNavigationControllerDelegateForHelptender *ret = (XTZNavigationControllerDelegateForHelptender *)[self xtz_getAssociatedObjectWithKey:&CHEAT_DELEGATE createIfNotExistWithBlock:^id {
		XTZNavigationControllerDelegateForHelptender *retIn = [XTZNavigationControllerDelegateForHelptender new];
		retIn.linkedNavigationController = self;
		return retIn;
	}];
	
	NSAssert([ret isKindOfClass:XTZNavigationControllerDelegateForHelptender.class], @"INTERNAL ERROR: Got invalid (not of class XTZNavigationControllerDelegateForHelptender) associated object %@ in %@.", ret, NSStringFromSelector(_cmd));
	NSAssert(ret.linkedNavigationController == self, @"INTERNAL ERROR: Got invalid linked navigation controller %@ for navigation controller %@.", ret.linkedNavigationController, self);
	return ret;
}

- (void)xtz_overrideDelegate
{
	NSParameterAssert(![self.delegate isKindOfClass:XTZNavigationControllerDelegateForHelptender.class]);
	self.delegate = self.delegate;
}

- (void)xtz_resetDelegate
{
	void (*setDelegateIMP)(id, SEL, id <UINavigationControllerDelegate>) = (void (*)(id, SEL, id <UINavigationControllerDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist.originalNavigationControllerDelegate);
	objc_setAssociatedObject(self, &CHEAT_DELEGATE, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/* Tells the table view the list of method the delegate responds to has changed. */
- (void)xtz_refreshDelegate
{
	id <UINavigationControllerDelegate> delegate = self.delegate;
	void (*setDelegateIMP)(id, SEL, id <UINavigationControllerDelegate>) = (void (*)(id, SEL, id <UINavigationControllerDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), nil);
	setDelegateIMP(self, @selector(setDelegate:), delegate);
}

- (void)setDelegate:(id <UINavigationControllerDelegate>)delegate
{
	if ([delegate isKindOfClass:XTZNavigationControllerDelegateForHelptender.class])
		delegate = ((XTZNavigationControllerDelegateForHelptender *)delegate).originalNavigationControllerDelegate;
	
	self.xtz_cheatDelegateCreateIfNotExist.originalNavigationControllerDelegate = delegate;
	void (*setDelegateIMP)(id, SEL, id <UINavigationControllerDelegate>) = (void (*)(id, SEL, id <UINavigationControllerDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), nil);
	setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist);
}

@end



@implementation XTZNavigationControllerDelegateForHelptender

- (void)dealloc
{
	self.originalNavigationControllerDelegate = nil;
}

- (void)setOriginalNavigationControllerDelegate:(id <UINavigationControllerDelegate>)delegate
{
	NSParameterAssert(![delegate isKindOfClass:XTZNavigationControllerDelegateForHelptender.class]);
	if (self.originalNavigationControllerDelegate == delegate)
		return;
	
	_originalNavigationControllerDelegate = delegate;
	if (_originalNavigationControllerDelegate != nil) previousNonNilOriginalDelegateClass = delegate.class;
}

- (void)navigationController:(XTZNavigationControllerHelptender *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	NSParameterAssert(navigationController == self.linkedNavigationController);
	
	for (NSObject <XTZNavigationControllerExtender> *extender in [navigationController xtz_extendersConformingToProtocol:@protocol(XTZNavigationControllerExtender)])
		if ([extender respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
			[extender navigationController:navigationController willShowViewController:viewController animated:animated];
	
	if ([self.originalNavigationControllerDelegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)])
		[self.originalNavigationControllerDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return ([super respondsToSelector:aSelector] ||
			  [self.originalNavigationControllerDelegate respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.originalNavigationControllerDelegate respondsToSelector:aSelector])
		return self.originalNavigationControllerDelegate;
	
	return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return ([super methodSignatureForSelector:aSelector]?:
			  [previousNonNilOriginalDelegateClass instanceMethodSignatureForSelector:aSelector]);
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[NSObject xtz_forwardInvocationLikeNil:anInvocation];
}

@end
