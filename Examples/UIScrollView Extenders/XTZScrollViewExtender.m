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

#import "XTZScrollViewExtender.h"

@import ObjectiveC.runtime;

@import eXtenderZ.HelptenderUtils;



static char DEALLOCING;
static char CHEAT_DELEGATE;
void * const SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE = &CHEAT_DELEGATE;
static char EXTENDERS_DID_SCROLL_KEY;
static char EXTENDERS_DID_END_DRAG_SCROLLING_KEY;
static char EXTENDERS_WILL_END_DRAG_SCROLLING_KEY;
static char EXTENDERS_DID_END_DECELERATING_SCROLL_KEY;
static char EXTENDERS_CONTENT_SIZE_WILL_CHANGE_KEY;
static char EXTENDERS_CONTENT_SIZE_DID_CHANGE_KEY;
static char EXTENDERS_CONTENT_INSET_WILL_CHANGE_KEY;
static char EXTENDERS_CONTENT_INSET_DID_CHANGE_KEY;

@implementation XTZScrollViewHelptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZScrollViewExtender)];
}

+ (void)xtz_helptenderHasBeenAdded:(XTZScrollViewHelptender *)helptender
{
	[helptender xtz_overrideDelegate];
}

+ (void)xtz_helptenderWillBeRemoved:(XTZScrollViewHelptender *)helptender
{
	[helptender xtz_resetDelegate];
	objc_setAssociatedObject(helptender, &EXTENDERS_DID_SCROLL_KEY,                  nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_DID_END_DRAG_SCROLLING_KEY,      nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_WILL_END_DRAG_SCROLLING_KEY,     nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_DID_END_DECELERATING_SCROLL_KEY, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_CONTENT_SIZE_WILL_CHANGE_KEY,    nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_CONTENT_SIZE_DID_CHANGE_KEY,     nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_CONTENT_INSET_WILL_CHANGE_KEY,   nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_CONTENT_INSET_DID_CHANGE_KEY,    nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	/* NOT setting SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE to nil: it can still be in use by a sub-helptender. */
}

- (BOOL)xtz_isDeallocing
{
	return (objc_getAssociatedObject(self, &DEALLOCING) != nil);
}

- (void)xtz_setDeallocing
{
	objc_setAssociatedObject(self, &DEALLOCING, NSNull.null, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersDidScroll,                EXTENDERS_DID_SCROLL_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersDidEndDragScrolling,      EXTENDERS_DID_END_DRAG_SCROLLING_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersWillEndDragScrolling,     EXTENDERS_WILL_END_DRAG_SCROLLING_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersDidEndDeceleratingScroll, EXTENDERS_DID_END_DECELERATING_SCROLL_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersContentWillSizeChange,    EXTENDERS_CONTENT_SIZE_WILL_CHANGE_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersContentDidSizeChange,     EXTENDERS_CONTENT_SIZE_DID_CHANGE_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersContentWillInsetChange,   EXTENDERS_CONTENT_INSET_WILL_CHANGE_KEY)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersContentDidInsetChange,    EXTENDERS_CONTENT_INSET_DID_CHANGE_KEY)

- (BOOL)xtz_prepareForExtender:(NSObject <XTZExtender> *)extender
{
	if (!((BOOL (*)(id, SEL, NSObject <XTZExtender> *))XTZ_HELPTENDER_CALL_SUPER(XTZScrollViewHelptender, extender))) return NO;
	
	if ([extender conformsToProtocol:@protocol(XTZScrollViewExtender)]) {
		if ([extender respondsToSelector:@selector(scrollViewDidScroll:)])                                        [[self xtz_extendersDidScrollCreateIfNotExist:YES]                addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewDidEndDecelerating:)])                               [[self xtz_extendersDidEndDeceleratingScrollCreateIfNotExist:YES] addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewDidEndDragScrolling:willDecelerate:)])               [[self xtz_extendersDidEndDragScrollingCreateIfNotExist:YES]      addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewWillChangeContentSize:newContentSize:)])             [[self xtz_extendersContentWillSizeChangeCreateIfNotExist:YES]    addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewDidChangeContentSize:originalContentSize:)])         [[self xtz_extendersContentDidSizeChangeCreateIfNotExist:YES]     addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewWillChangeContentInset:newContentInset:)])           [[self xtz_extendersContentWillInsetChangeCreateIfNotExist:YES]   addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewDidChangeContentInset:originalContentInset:)])       [[self xtz_extendersContentDidInsetChangeCreateIfNotExist:YES]    addObject:extender];
		if ([extender respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) [[self xtz_extendersWillEndDragScrollingCreateIfNotExist:YES]     addObject:extender];
		
		[self xtz_refreshDelegate];
	}
	
	return YES;
}

- (void)xtz_removeExtender:(NSObject <XTZExtender> *)extender atIndex:(NSUInteger)idx
{
	if ([extender conformsToProtocol:@protocol(XTZScrollViewExtender)]) {
		[self.xtz_extendersDidScroll                removeObjectIdenticalTo:extender];
		[self.xtz_extendersDidEndDragScrolling      removeObjectIdenticalTo:extender];
		[self.xtz_extendersWillEndDragScrolling     removeObjectIdenticalTo:extender];
		[self.xtz_extendersDidEndDeceleratingScroll removeObjectIdenticalTo:extender];
		[self.xtz_extendersContentWillSizeChange    removeObjectIdenticalTo:extender];
		[self.xtz_extendersContentDidSizeChange     removeObjectIdenticalTo:extender];
		[self.xtz_extendersContentWillInsetChange   removeObjectIdenticalTo:extender];
		[self.xtz_extendersContentDidInsetChange    removeObjectIdenticalTo:extender];
		
		[self xtz_refreshDelegate];
	}
	
	((void (*)(id, SEL, NSObject <XTZExtender> *, NSUInteger))XTZ_HELPTENDER_CALL_SUPER(XTZScrollViewHelptender, extender, idx));
}

- (void)xtz_prepareDeallocationOfExtendedObject
{
	[self xtz_setDeallocing];
	((void (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZScrollViewHelptender));
}

#pragma mark - Overrides of UIScrollView

- (void)setContentSize:(CGSize)contentSize
{
	CGSize ori = self.contentSize;
	
	BOOL isDifferent = (ABS(contentSize.width - ori.width) > 0.01 || ABS(contentSize.height - ori.height) > 0.01);
	
	if (isDifferent) {
		for (NSObject <XTZScrollViewExtender> *extender in self.xtz_extendersContentWillSizeChange)
			[extender scrollViewWillChangeContentSize:self newContentSize:contentSize];
	}
	
	((void (*)(id, SEL, CGSize))XTZ_HELPTENDER_CALL_SUPER(XTZScrollViewHelptender, contentSize));
	
	if (isDifferent) {
		for (NSObject <XTZScrollViewExtender> *extender in self.xtz_extendersContentDidSizeChange)
			[extender scrollViewDidChangeContentSize:self originalContentSize:ori];
	}
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
	UIEdgeInsets ori = self.contentInset;
	
	for (NSObject <XTZScrollViewExtender> *extender in self.xtz_extendersContentWillInsetChange)
		[extender scrollViewWillChangeContentInset:self newContentInset:contentInset];
	
	((void (*)(id, SEL, UIEdgeInsets))XTZ_HELPTENDER_CALL_SUPER(XTZScrollViewHelptender, contentInset));
	
	for (NSObject <XTZScrollViewExtender> *extender in self.xtz_extendersContentDidInsetChange)
		[extender scrollViewDidChangeContentInset:self originalContentInset:ori];
}

#pragma mark - Delegate Overriding

- (XTZScrollViewDelegateForHelptender *)xtz_cheatDelegateCreateIfNotExist
{
	XTZScrollViewDelegateForHelptender *ret = (XTZScrollViewDelegateForHelptender *)[self xtz_getAssociatedObjectWithKey:SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE createIfNotExistWithBlock:^id{
		XTZScrollViewDelegateForHelptender *retIn = [XTZScrollViewDelegateForHelptender new];
		retIn.linkedView = self;
		return retIn;
	}];
	
	NSAssert([ret isKindOfClass:XTZScrollViewDelegateForHelptender.class], @"INTERNAL ERROR: Got invalid (not of class XTZScrollViewDelegateForHelptender) associated object %@ in %@.", ret, NSStringFromSelector(_cmd));
	NSAssert(ret.linkedView == self, @"INTERNAL ERROR: Got invalid linked view %@ for scroll view %@.", ret.linkedView, self);
	return ret;
}

- (void)xtz_overrideDelegate
{
	NSParameterAssert(![self.delegate isKindOfClass:XTZScrollViewDelegateForHelptender.class]);
	self.delegate = self.delegate;
}

- (void)xtz_resetDelegate
{
	/* We are NOT modifying the delegate when we’re deallocing,
	 *  or if we are a table view and the data source has been dealloced when we’re here (most likely to happen when we’re deallocing),
	 *  the table view may try calling its datasource, which would crash.
	 * (The table view does not keep a weak ref to the data source…)
	 *
	 * Another better solution would be to force the table view to have a weak data source instead of a simple assign (MAZeroingWeakRef). */
	if (!self.xtz_isDeallocing) {
		void (*setDelegateIMP)(id, SEL, id <UIScrollViewDelegate>) = (void (*)(id, SEL, id <UIScrollViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
		setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist.originalScrollViewDelegate);
	}
	objc_setAssociatedObject(self, SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/* Tells the table view the list of method the delegate responds to has changed. */
- (void)xtz_refreshDelegate
{
	/* Does not seem to be required, but to be symetric with refresh data source, I’ll let this here. */
	if (self.xtz_isDeallocing) return;
	
	[self.xtz_cheatDelegateCreateIfNotExist refreshKnownOriginalResponds];
	
	id <UIScrollViewDelegate> delegate = self.delegate;
	void (*setDelegateIMP)(id, SEL, id <UIScrollViewDelegate>) = (void (*)(id, SEL, id <UIScrollViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), nil);
	setDelegateIMP(self, @selector(setDelegate:), delegate);
}

- (void)setDelegate:(id <UIScrollViewDelegate>)delegate
{
	if ([delegate isKindOfClass:XTZScrollViewDelegateForHelptender.class])
		delegate = ((XTZScrollViewDelegateForHelptender *)delegate).originalScrollViewDelegate;
	
	self.xtz_cheatDelegateCreateIfNotExist.originalScrollViewDelegate = delegate;
	void (*setDelegateIMP)(id, SEL, id <UIScrollViewDelegate>) = (void (*)(id, SEL, id <UIScrollViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), nil);
	setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist);
}

@end



@implementation XTZScrollViewDelegateForHelptender

+ (instancetype)scrollViewDelegateForHelptenderFromScrollViewDelegateForHelptender:(XTZScrollViewDelegateForHelptender *)original
{
	XTZScrollViewDelegateForHelptender *ret = [self new];
	ret.linkedView = original.linkedView;
	ret.originalScrollViewDelegate = original.originalScrollViewDelegate;
	return ret;
}

- (void)dealloc
{
	self.originalScrollViewDelegate = nil;
}

- (void)refreshKnownOriginalResponds
{
	odRespondsToDidScroll = [self.originalScrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)];
}

- (void)setOriginalScrollViewDelegate:(id <UIScrollViewDelegate>)delegate
{
	NSParameterAssert(![delegate isKindOfClass:XTZScrollViewDelegateForHelptender.class]);
	if (self.originalScrollViewDelegate == delegate)
		return;
	
	_originalScrollViewDelegate = delegate;
	if (_originalScrollViewDelegate != nil) previousNonNilOriginalDelegateClass = delegate.class;
	
	[self refreshKnownOriginalResponds];
}

- (void)scrollViewDidScroll:(XTZScrollViewHelptender *)scrollView
{
	NSParameterAssert(scrollView == self.linkedView);
	
	for (NSObject <XTZScrollViewExtender> *extender in scrollView.xtz_extendersDidScroll)
		[extender scrollViewDidScroll:scrollView];
	
	if (odRespondsToDidScroll)
		[self.originalScrollViewDelegate scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(XTZScrollViewHelptender *)scrollView willDecelerate:(BOOL)decelerate
{
	NSParameterAssert(scrollView == self.linkedView);
	
	for (NSObject <XTZScrollViewExtender> *extender in scrollView.xtz_extendersDidEndDragScrolling)
		[extender scrollViewDidEndDragScrolling:scrollView willDecelerate:decelerate];
	
	if ([self.originalScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
		[self.originalScrollViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillEndDragging:(XTZScrollViewHelptender *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	NSParameterAssert(scrollView == self.linkedView);
	
	for (NSObject <XTZScrollViewExtender> *extender in scrollView.xtz_extendersWillEndDragScrolling)
		[extender scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
	
	if ([self.originalScrollViewDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
		[self.originalScrollViewDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDecelerating:(XTZScrollViewHelptender *)scrollView
{
	NSParameterAssert(scrollView == self.linkedView);
	
	for (NSObject <XTZScrollViewExtender> *extender in scrollView.xtz_extendersDidEndDeceleratingScroll)
		[extender scrollViewDidEndDecelerating:scrollView];
	
	if ([self.originalScrollViewDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
		[self.originalScrollViewDelegate scrollViewDidEndDecelerating:scrollView];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return ([super respondsToSelector:aSelector] ||
			  [self.originalScrollViewDelegate respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.originalScrollViewDelegate respondsToSelector:aSelector])
		return self.originalScrollViewDelegate;
	
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
