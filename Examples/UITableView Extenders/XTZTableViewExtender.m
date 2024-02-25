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

#import "XTZTableViewExtender.h"

@import ObjectiveC.runtime;

@import eXtenderZ.HelptenderUtils;



@interface XTZTableViewHelptender ()

- (NSIndexPath *)xtz_transformedIndexPath:(NSIndexPath *)indexPath;

@end



static char DEALLOCING;
static char HEADER_VIEWS, FOOTER_VIEWS;
static char CACHED_TRANSFORMED_INDEX_PATHS;
static char EXTENDERS_TRANSFORM_SECTION;
static char EXTENDERS_TRANSFORM_CELL_WIDTH;
static char EXTENDERS_TRANSFORM_CELL_HEIGHT;
static char EXTENDERS_TRANSFORM_CELL;
static char EXTENDERS_TRANSFORM_NUMBER_OF_SECTIONS;

@implementation XTZTableViewHelptender

+ (void)load
{
	[self xtz_registerClass:self asHelptenderForProtocol:@protocol(XTZTableViewExtender)];
}

+ (void)xtz_helptenderHasBeenAdded:(XTZTableViewHelptender *)helptender
{
	[helptender xtz_overrideDelegateAndDataSource];
}

+ (void)xtz_helptenderWillBeRemoved:(XTZTableViewHelptender *)helptender
{
	[helptender xtz_resetDelegateAndDataSource];
	objc_setAssociatedObject(helptender, &HEADER_VIEWS,                           nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &FOOTER_VIEWS,                           nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &CACHED_TRANSFORMED_INDEX_PATHS,         nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_TRANSFORM_SECTION,            nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_TRANSFORM_CELL_WIDTH,         nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_TRANSFORM_CELL_HEIGHT,        nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_TRANSFORM_CELL,               nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(helptender, &EXTENDERS_TRANSFORM_NUMBER_OF_SECTIONS, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	/* NOT setting SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE to nil: it can still be in use by the scroll view helptender. */
}

- (BOOL)xtz_isDeallocing
{
	return (objc_getAssociatedObject(self, &DEALLOCING) != nil);
}

- (void)xtz_setDeallocing
{
	objc_setAssociatedObject(self, &DEALLOCING, NSNull.null, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CFMutableDictionaryRef)xtz_headerViews
{
	return [self xtz_headerViewsCreateIfNotExist:NO];
}

- (CFMutableDictionaryRef)xtz_footerViews
{
	return [self xtz_footerViewsCreateIfNotExist:NO];
}

- (CFMutableDictionaryRef)xtz_headerViewsCreateIfNotExist:(BOOL)createIfNeeded
{
	id ret = [self xtz_getAssociatedObjectWithKey:&HEADER_VIEWS createIfNotExistWithBlock:(createIfNeeded? ^id{
		return (NSMutableDictionary *)CFBridgingRelease(CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks));
	}: NULL)];
	
	NSAssert(ret == nil || [ret isKindOfClass:NSMutableDictionary.class], @"***** INTERNAL ERROR: Got invalid (not of class NSMutableDictionary) associated object %@ in %@", ret, NSStringFromSelector(_cmd));
	
	if (ret == nil) return NULL;
	return (CFMutableDictionaryRef)CFAutorelease(CFBridgingRetain(ret));
}

- (CFMutableDictionaryRef)xtz_footerViewsCreateIfNotExist:(BOOL)createIfNeeded
{
	id ret = [self xtz_getAssociatedObjectWithKey:&FOOTER_VIEWS createIfNotExistWithBlock:(createIfNeeded? ^id{
		return (NSMutableDictionary *)CFBridgingRelease(CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks));
	}: NULL)];
	
	NSAssert(ret == nil || [ret isKindOfClass:NSMutableDictionary.class], @"***** INTERNAL ERROR: Got invalid (not of class NSMutableDictionary) associated object %@ in %@", ret, NSStringFromSelector(_cmd));
	
	if (ret == nil) return NULL;
	return (CFMutableDictionaryRef)CFAutorelease(CFBridgingRetain(ret));
}

- (NSCache *)xtz_cacheForTransformedIndexPaths
{
	return [self xtz_cacheForTransformedIndexPathsCreateIfNotExist:NO];
}

- (NSCache *)xtz_cacheForTransformedIndexPathsCreateIfNotExist:(BOOL)createIfNeeded
{
	id ret = [self xtz_getAssociatedObjectWithKey:&CACHED_TRANSFORMED_INDEX_PATHS createIfNotExistWithBlock:(createIfNeeded? ^id{
		NSCache *cache = [NSCache new];
		cache.name = [NSString stringWithFormat:@"Cache for Table View Extender %p", self];
		cache.countLimit = 75;
		return cache;
	}: NULL)];
	
	NSAssert(ret == nil || [ret isKindOfClass:NSCache.class], @"***** INTERNAL ERROR: Got invalid (not of class NSCache) associated object %@ in %@", ret, NSStringFromSelector(_cmd));
	return ret;
}

XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersTransformSection,          EXTENDERS_TRANSFORM_SECTION)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersTransformCellWidth,        EXTENDERS_TRANSFORM_CELL_WIDTH)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersTransformCellHeight,       EXTENDERS_TRANSFORM_CELL_HEIGHT)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersTransformCell,             EXTENDERS_TRANSFORM_CELL)
XTZ_DYNAMIC_ACCESSOR(NSMutableArray, xtz_extendersTransformNumberOfSections, EXTENDERS_TRANSFORM_NUMBER_OF_SECTIONS)

#pragma mark - Standard

- (NSInteger)xtz_transformedSectionIndex:(NSInteger)section
{
	for (NSObject <XTZTableViewExtender> *extender in self.xtz_extendersTransformSection)
		section = [extender transformedSectionIndexFrom:section withRow:-1 inTableView:self];
	
	return section;
}

- (NSIndexPath *)xtz_transformedIndexPath:(NSIndexPath *)indexPath
{
	id <UITableViewDataSource> ods = self.xtz_cheatDataSourceCreateIfNotExist.originalTableViewDataSource;
	NSString *identifier = [NSString stringWithFormat:@"%"NSINT_FMT".%"NSINT_FMT".%"NSINT_FMT".%"NSINT_FMT,
									indexPath.section, indexPath.row,
									[ods respondsToSelector:@selector(numberOfSectionsInTableView:)]? [ods numberOfSectionsInTableView:self]: 1,
									[ods tableView:self numberOfRowsInSection:[self xtz_transformedSectionIndex:indexPath.section]]];
	NSIndexPath *cachedIndexPath = [self.xtz_cacheForTransformedIndexPaths objectForKey:identifier];
	NSAssert(cachedIndexPath == nil || [cachedIndexPath isKindOfClass:NSIndexPath.class], @"***** INTERNAL ERROR: Got invalid cached index path %@", cachedIndexPath);
	if (cachedIndexPath != nil) return cachedIndexPath;
	
	NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;
	
	for (NSObject <XTZTableViewExtender> *extender in self.xtz_extenders) {
		NSInteger newRow = row;
		NSInteger newSection = section;
		if ([extender respondsToSelector:@selector(transformedRowIndexFrom:inSection:inTableView:)])
			newRow = [extender transformedRowIndexFrom:row inSection:section inTableView:self];
		if ([extender respondsToSelector:@selector(transformedSectionIndexFrom:withRow:inTableView:)])
			newSection = [extender transformedSectionIndexFrom:section withRow:row inTableView:self];
		row = newRow;
		section = newSection;
	}
	
	NSIndexPath *ret = [NSIndexPath indexPathForRow:row inSection:section];
	[[self xtz_cacheForTransformedIndexPathsCreateIfNotExist:YES] setObject:ret forKey:identifier];
	return ret;
}

- (NSArray *)xtz_transformedIndexPaths:(NSArray *)indexPaths
{
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:indexPaths.count];
	for (NSIndexPath *indexPath in indexPaths)
		[ret addObject:[self xtz_transformedIndexPath:indexPath]];
	
	return ret;
}

- (CGFloat)xtz_cellWidthForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat w = self.bounds.size.width;
	indexPath = [self xtz_transformedIndexPath:indexPath];
	for (NSObject <XTZTableViewExtender> *extender in self.xtz_extendersTransformCellWidth)
		w = [extender transformWidth:w forRowAtIndex:indexPath.row inSection:indexPath.section inTableView:self];
	
	return w;
}

- (UIView *)xtz_viewInTableHeaderForExtender:(id <XTZTableViewExtender>)extender
{
	CFDictionaryRef d = self.xtz_headerViews;
	UIView *v = (d != NULL? CFBridgingRelease(CFRetain(CFDictionaryGetValue(d, (__bridge const void *)extender))): nil);
	if (v == nil) [NSException raise:@"Unknown extender" format:@"The extender %@ is not registered in the table view %@", extender, self];
	
	NSAssert([v isEqual:NSNull.null] || [v isKindOfClass:UIView.class], @"Invalid header view %@", v);
	return [v isEqual:NSNull.null]? nil: v;
}

- (UIView *)xtz_viewInTableFooterForExtender:(id <XTZTableViewExtender>)extender
{
	CFDictionaryRef d = self.xtz_footerViews;
	UIView *v = (d != NULL? CFBridgingRelease(CFRetain(CFDictionaryGetValue(d, (__bridge const void *)extender))): nil);
	if (v == nil) [NSException raise:@"Unknown extender" format:@"The extender %@ is not registered in the table view %@", extender, self];
	
	NSAssert([v isEqual:NSNull.null] || [v isKindOfClass:UIView.class], @"Invalid footer view %@", v);
	return [v isEqual:NSNull.null]? nil: v;
}

#pragma mark - Overrides

- (BOOL)xtz_prepareForExtender:(NSObject <XTZTableViewExtender> *)extender
{
	if (![extender conformsToProtocol:@protocol(XTZTableViewExtender)])
		return ((BOOL (*)(id, SEL, NSObject <XTZTableViewExtender> *))XTZ_HELPTENDER_CALL_SUPER(XTZTableViewHelptender, extender));
	
	
	if ([extender respondsToSelector:@selector(needsSubviewInTableHeaderView)] && [extender needsSubviewInTableHeaderView]) {
		if (self.tableHeaderView == nil) {
			self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.bounds.size.width, 0.)];
			self.tableHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
		}
		UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0., self.tableHeaderView.bounds.size.height, self.tableHeaderView.bounds.size.width, 0.)];
		subview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		[self.tableHeaderView addSubview:subview];
		CFDictionarySetValue([self xtz_headerViewsCreateIfNotExist:YES], (__bridge const void *)extender, CFAutorelease(CFBridgingRetain(subview)));
	} else {
		CFDictionarySetValue([self xtz_headerViewsCreateIfNotExist:YES], (__bridge const void *)extender, CFAutorelease(CFBridgingRetain(NSNull.null)));
	}
	
	if ([extender respondsToSelector:@selector(needsSubviewInTableFooterView)] && [extender needsSubviewInTableFooterView]) {
		if (self.tableFooterView == nil) {
			self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.bounds.size.width, 0.)];
			self.tableFooterView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		}
		UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.tableFooterView.bounds.size.width, 0.)];
		subview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
		[self.tableFooterView addSubview:subview];
		CFDictionarySetValue([self xtz_footerViewsCreateIfNotExist:YES], (__bridge const void *)extender, CFAutorelease(CFBridgingRetain(subview)));
	} else {
		CFDictionarySetValue([self xtz_footerViewsCreateIfNotExist:YES], (__bridge const void *)extender, CFAutorelease(CFBridgingRetain(NSNull.null)));
	}
	
	if (!((BOOL (*)(id, SEL, NSObject <XTZTableViewExtender> *))XTZ_HELPTENDER_CALL_SUPER(XTZTableViewHelptender, extender))) {
		[[self xtz_viewInTableHeaderForExtender:extender] removeFromSuperview];
		[[self xtz_viewInTableFooterForExtender:extender] removeFromSuperview];
		CFDictionaryRemoveValue([self xtz_headerViewsCreateIfNotExist:YES], (__bridge const void *)extender);
		CFDictionaryRemoveValue([self xtz_footerViewsCreateIfNotExist:YES], (__bridge const void *)extender);
		return NO;
	}
	
	if ([extender respondsToSelector:@selector(transformedSectionIndexFrom:withRow:inTableView:)])     [[self xtz_extendersTransformSectionCreateIfNotExist:YES] addObject:extender];
	if ([extender respondsToSelector:@selector(transformWidth:forRowAtIndex:inSection:inTableView:)])  [[self xtz_extendersTransformCellWidthCreateIfNotExist:YES] addObject:extender];
	if ([extender respondsToSelector:@selector(transformHeight:forRowAtIndex:inSection:inTableView:)]) [[self xtz_extendersTransformCellHeightCreateIfNotExist:YES] addObject:extender];
	if ([extender respondsToSelector:@selector(transformCell:forRowAtIndex:inSection:inTableView:)])   [[self xtz_extendersTransformCellCreateIfNotExist:YES] addObject:extender];
	if ([extender respondsToSelector:@selector(transformedNumberOfSectionsFrom:inTableView:)]) {
		[[self xtz_extendersTransformNumberOfSectionsCreateIfNotExist:YES] addObject:extender];
		NSAssert([extender respondsToSelector:@selector(transformedNumberOfRowsFrom:inSection:inTableView:)], @"***** Invalid extender %@: Changes the number of sections, but not the number of rows.", extender);
		NSAssert([extender respondsToSelector:@selector(transformedSectionIndexFrom:withRow:inTableView:)], @"***** Invalid extender %@: Changes the number of sections, but not the index of the section.", extender);
		NSAssert([extender respondsToSelector:@selector(transformedRowIndexFrom:inSection:inTableView:)], @"***** Invalid extender %@: Changes the number of sections, but not the index of the row.", extender);
	} else {
		NSAssert(![extender respondsToSelector:@selector(transformedNumberOfRowsFrom:inSection:inTableView:)], @"***** Invalid extender %@: Changes the number of rows, but not the number of sections.", extender);
	}
	[self xtz_refreshDelegateAndDataSource];
	[self.xtz_cacheForTransformedIndexPaths removeAllObjects];
	
	return YES;
}

- (void)xtz_removeExtender:(NSObject <XTZTableViewExtender> *)extender atIndex:(NSUInteger)idx
{
	if ([extender conformsToProtocol:@protocol(XTZTableViewExtender)]) {
		[self.xtz_extendersTransformSection removeObjectIdenticalTo:extender];
		[self.xtz_extendersTransformCellWidth removeObjectIdenticalTo:extender];
		[self.xtz_extendersTransformCellHeight removeObjectIdenticalTo:extender];
		[self.xtz_extendersTransformCell removeObjectIdenticalTo:extender];
		[self.xtz_extendersTransformNumberOfSections removeObjectIdenticalTo:extender];
		
		[[self xtz_viewInTableHeaderForExtender:extender] removeFromSuperview];
		[[self xtz_viewInTableFooterForExtender:extender] removeFromSuperview];
		CFDictionaryRemoveValue([self xtz_headerViewsCreateIfNotExist:YES], (__bridge const void *)extender);
		CFDictionaryRemoveValue([self xtz_footerViewsCreateIfNotExist:YES], (__bridge const void *)extender);
		
		[self xtz_refreshDelegateAndDataSource];
		[self.xtz_cacheForTransformedIndexPaths removeAllObjects];
	}
	
	((void (*)(id, SEL, NSObject <XTZTableViewExtender> *, NSUInteger))XTZ_HELPTENDER_CALL_SUPER(XTZTableViewHelptender, extender, idx));
}

- (void)xtz_prepareDeallocationOfExtendedObject
{
	[self xtz_setDeallocing];
	((void (*)(id, SEL))XTZ_HELPTENDER_CALL_SUPER_NO_ARGS(XTZTableViewHelptender));
}

#pragma mark - Delegate And Data Source Overriding

- (XTZTableViewDelegateDataSourceForHelptender *)xtz_cheatDelegateCreateIfNotExist
{
	XTZTableViewDelegateDataSourceForHelptender *ret = (XTZTableViewDelegateDataSourceForHelptender *)[self xtz_getAssociatedObjectWithKey:SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE createIfNotExistWithBlock:^id{
		XTZTableViewDelegateDataSourceForHelptender *retIn = [XTZTableViewDelegateDataSourceForHelptender new];
		retIn.linkedView = self;
		return retIn;
	}];
	NSAssert(ret.linkedView == self, @"INTERNAL ERROR: Got invalid linked view %@ for scroll view %@.", ret.linkedView, self);
	
	if (![ret isKindOfClass:XTZTableViewDelegateDataSourceForHelptender.class]) {
		NSAssert([ret isKindOfClass:XTZScrollViewDelegateForHelptender.class], @"INTERNAL ERROR: Got invalid (not of class XTZScrollViewDelegateForHelptender) associated object %@ in %@.", ret, NSStringFromSelector(_cmd));
		ret = [XTZTableViewDelegateDataSourceForHelptender scrollViewDelegateForHelptenderFromScrollViewDelegateForHelptender:ret];
		ret.linkedView = self;
		objc_setAssociatedObject(self, SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return ret;
}

- (XTZTableViewDelegateDataSourceForHelptender *)xtz_cheatDataSourceCreateIfNotExist
{
	return self.xtz_cheatDelegateCreateIfNotExist;
}

- (void)xtz_overrideDelegate
{
	/* The parameter assert below is INVALID!
	 * If you add an extender that needs the scroll view AND table view helptender,
	 *  the override delegate of the scroll view helptender will be called AFTER the one of the table view,
	 *  and self.delegate will already be kind of class XTZTableViewDelegateDataSourceForHelptender when we get here from the scroll view helptender. */
//	NSParameterAssert(![self.delegate isKindOfClass:XTZTableViewDelegateDataSourceForHelptender.class]);
	self.delegate = self.delegate;
}

- (void)xtz_resetDelegate
{
	void (*setDelegateIMP)(id, SEL, id <UITableViewDelegate>) = (void (*)(id, SEL, id <UITableViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist.originalTableViewDelegate);
	if (self.dataSource != objc_getAssociatedObject(self, SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE))
		objc_setAssociatedObject(self, SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/* Tells the table view the list of method the delegate responds to has changed. */
- (void)xtz_refreshDelegate
{
	/* In certain conditions, the modification of the delegate might make the table view crash if the data source is not nil
	 *  (this crash occurs probably during deallocations or removal of extenders, the exact circumstances are not clear). */
	id <UITableViewDataSource> dataSource = self.dataSource;
	self.dataSource = nil;
	
	[self.xtz_cheatDataSourceCreateIfNotExist refreshKnownOriginalResponds];
	
	/* Does not seem to be required, but to be symetric with refresh data source, I’ll let this here. */
	if (self.xtz_isDeallocing) return;
	
	id <UITableViewDelegate> delegate = self.delegate;
	void (*setDelegateIMP)(id, SEL, id <UITableViewDelegate>) = (void (*)(id, SEL, id <UITableViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), nil);
	setDelegateIMP(self, @selector(setDelegate:), delegate);
	
	/* Let’s reset the data source to the previous value. */
	self.dataSource = dataSource;
}

- (void)xtz_overrideDataSource
{
	NSParameterAssert(![self.dataSource isKindOfClass:XTZTableViewDelegateDataSourceForHelptender.class]);
	self.dataSource = self.dataSource;
}

- (void)xtz_resetDataSource
{
	void (*setDataSourceIMP)(id, SEL, id <UITableViewDataSource>) = (void (*)(id, SEL, id <UITableViewDataSource>))class_getMethodImplementation(self.class, @selector(setDataSource:));
	setDataSourceIMP(self, @selector(setDataSource:), self.xtz_cheatDelegateCreateIfNotExist.originalTableViewDataSource);
	if (self.delegate != objc_getAssociatedObject(self, SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE))
		objc_setAssociatedObject(self, SCROLL_VIEW_EXTENDER_CHEAT_REFERENCE, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/* Tells the table view the list of method the data source responds to has changed. */
- (void)xtz_refreshDataSource
{
	[self.xtz_cheatDataSourceCreateIfNotExist refreshKnownOriginalResponds];
	
	/* Might crash when deallocing on iOS 9 (we’re deallocing, dropping the refresh of the data source is no big deal). */
	if (self.xtz_isDeallocing) return;
	
	id <UITableViewDataSource> dataSource = self.dataSource;
	void (*setDataSourceIMP)(id, SEL, id <UITableViewDataSource>) = (void (*)(id, SEL, id <UITableViewDataSource>))class_getMethodImplementation(self.class, @selector(setDataSource:));
	setDataSourceIMP(self, @selector(setDataSource:), nil);
	setDataSourceIMP(self, @selector(setDataSource:), dataSource);
}

- (void)xtz_overrideDelegateAndDataSource
{
	[self xtz_overrideDelegate];
	[self xtz_overrideDataSource];
}

- (void)xtz_resetDelegateAndDataSource
{
	[self xtz_resetDelegate];
	[self xtz_resetDataSource];
}

- (void)xtz_refreshDelegateAndDataSource
{
	[self xtz_refreshDelegate];
	[self xtz_refreshDataSource];
}

- (void)setDelegate:(id <UITableViewDelegate>)delegate
{
	if ([delegate isKindOfClass:XTZScrollViewDelegateForHelptender.class])
		delegate = (id <UITableViewDelegate>)((XTZScrollViewDelegateForHelptender *)delegate).originalScrollViewDelegate;
	
	self.xtz_cheatDelegateCreateIfNotExist.originalTableViewDelegate = delegate;
	void (*setDelegateIMP)(id, SEL, id <UITableViewDelegate>) = (void (*)(id, SEL, id <UITableViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	setDelegateIMP(self, @selector(setDelegate:), nil);
	setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist);
}

- (void)setDataSource:(id <UITableViewDataSource>)dataSource
{
	if ([dataSource isKindOfClass:XTZTableViewDelegateDataSourceForHelptender.class])
		dataSource = ((XTZTableViewDelegateDataSourceForHelptender *)dataSource).originalTableViewDataSource;
	
	self.xtz_cheatDelegateCreateIfNotExist.originalTableViewDataSource = dataSource;
	void (*setDataSourceIMP)(id, SEL, id <UITableViewDataSource>) = (void (*)(id, SEL, id <UITableViewDataSource>))class_getMethodImplementation(self.class, @selector(setDataSource:));
	setDataSourceIMP(self, @selector(setDataSource:), nil);
	setDataSourceIMP(self, @selector(setDataSource:), self.xtz_cheatDelegateCreateIfNotExist);
}

- (void)setDelegate:(id <UITableViewDelegate>)delegate andDataSource:(id <UITableViewDataSource>)dataSource
{
	if ([delegate isKindOfClass:XTZScrollViewDelegateForHelptender.class])
		delegate = (id <UITableViewDelegate>)((XTZScrollViewDelegateForHelptender *)delegate).originalScrollViewDelegate;
	if ([dataSource isKindOfClass:XTZTableViewDelegateDataSourceForHelptender.class])
		dataSource = ((XTZTableViewDelegateDataSourceForHelptender *)dataSource).originalTableViewDataSource;
	
	self.xtz_cheatDelegateCreateIfNotExist.originalTableViewDelegate = delegate;
	self.xtz_cheatDelegateCreateIfNotExist.originalTableViewDataSource = dataSource;
	
	void (*setDelegateIMP)(id, SEL, id <UITableViewDelegate>) = (void (*)(id, SEL, id <UITableViewDelegate>))class_getMethodImplementation(self.class, @selector(setDelegate:));
	void (*setDataSourceIMP)(id, SEL, id <UITableViewDataSource>) = (void (*)(id, SEL, id <UITableViewDataSource>))class_getMethodImplementation(self.class, @selector(setDataSource:));
	
	setDataSourceIMP(self, @selector(setDataSource:), nil);
	setDelegateIMP(self, @selector(setDelegate:), nil);
	
	setDataSourceIMP(self, @selector(setDataSource:), self.xtz_cheatDelegateCreateIfNotExist);
	setDelegateIMP(self, @selector(setDelegate:), self.xtz_cheatDelegateCreateIfNotExist);
}

@end



@implementation UITableView (RecommendedConvenience)

/* Completely overwritten when the table view is extended. */
- (void)setDelegate:(id <UITableViewDelegate>)delegate andDataSource:(id <UITableViewDataSource>)dataSource
{
	self.dataSource = nil;
	self.delegate = delegate;
	self.dataSource = dataSource;
}

@end



@implementation XTZTableViewDelegateDataSourceForHelptender

@dynamic linkedView; /* Implemented by superclass. */

- (void)dealloc
{
	self.originalTableViewDelegate = nil;
	self.originalTableViewDataSource = nil;
}

- (id <UITableViewDelegate>)originalTableViewDelegate
{
	return (id <UITableViewDelegate>)self.originalScrollViewDelegate;
}

- (void)setOriginalTableViewDelegate:(id <UITableViewDelegate>)originalTableViewDelegate
{
	NSParameterAssert(![originalTableViewDelegate isKindOfClass:XTZScrollViewDelegateForHelptender.class]);
	self.originalScrollViewDelegate = originalTableViewDelegate;
}

- (void)setOriginalTableViewDataSource:(id <UITableViewDataSource>)dataSource
{
	NSParameterAssert(![dataSource isKindOfClass:XTZScrollViewDelegateForHelptender.class]);
	if (self.originalTableViewDataSource == dataSource)
		return;
	
	_originalTableViewDataSource = dataSource;
	if (_originalTableViewDataSource != nil) previousNonNilOriginalDataSourceClass = dataSource.class;
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInTableView:(XTZTableViewHelptender *)tableView
{
	NSParameterAssert(tableView == self.linkedView);
	
	NSInteger numberOfSections = 1;
	if ([self.originalTableViewDataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
		numberOfSections = [self.originalTableViewDataSource numberOfSectionsInTableView:tableView];
	
	for (NSObject <XTZTableViewExtender> *extender in tableView.xtz_extendersTransformNumberOfSections)
		numberOfSections = [extender transformedNumberOfSectionsFrom:numberOfSections inTableView:tableView];
	
	return numberOfSections;
}

- (NSInteger)tableView:(XTZTableViewHelptender *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSParameterAssert(tableView == self.linkedView);
	
	/* We do *NOT* transform the section index when calling the original data source. */
	NSInteger numberOfRows = [self.originalTableViewDataSource tableView:tableView numberOfRowsInSection:section];
	
	for (NSObject <XTZTableViewExtender> *extender in tableView.xtz_extendersTransformNumberOfSections) {
		if ([extender respondsToSelector:@selector(transformedSectionIndexFrom:withRow:inTableView:)])
			section = [extender transformedSectionIndexFrom:section withRow:-1 inTableView:tableView];
		numberOfRows = [extender transformedNumberOfRowsFrom:numberOfRows inSection:section inTableView:tableView];
	}
	
	return numberOfRows;
}

- (UITableViewCell *)tableView:(XTZTableViewHelptender *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSParameterAssert(tableView == self.linkedView);
	
	/* We do *NOT* transform the index path when calling the original data source. */
	UITableViewCell *cell = [self.originalTableViewDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
	
	indexPath = [tableView xtz_transformedIndexPath:indexPath];
	for (NSObject <XTZTableViewExtender> *extender in tableView.xtz_extendersTransformCell)
		[extender transformCell:cell forRowAtIndex:indexPath.row inSection:indexPath.section inTableView:tableView];
	
	return cell;
}

#pragma mark - Delegate

- (CGFloat)tableView:(XTZTableViewHelptender *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSParameterAssert(tableView == self.linkedView);
	
	CGFloat height = tableView.rowHeight;
	if ([self.originalTableViewDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
		height = [self.originalTableViewDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
	
	indexPath = [tableView xtz_transformedIndexPath:indexPath];
	for (NSObject <XTZTableViewExtender> *extender in tableView.xtz_extendersTransformCellHeight)
		height = [extender transformHeight:height forRowAtIndex:indexPath.row inSection:indexPath.section inTableView:tableView];
	
	return height;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return ([super respondsToSelector:aSelector] ||
			  [self.originalTableViewDelegate respondsToSelector:aSelector] ||
			  [self.originalTableViewDataSource respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
	if ([self.originalTableViewDelegate respondsToSelector:aSelector])
		return self.originalTableViewDelegate;
	
	if ([self.originalTableViewDataSource respondsToSelector:aSelector])
		return self.originalTableViewDataSource;
	
	return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return ([super methodSignatureForSelector:aSelector]?:
			  [previousNonNilOriginalDataSourceClass instanceMethodSignatureForSelector:aSelector]);
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[NSObject xtz_forwardInvocationLikeNil:anInvocation];
}

@end



static char IS_TRANSFORMED_DICTIONARY_KEY;

@implementation UITableViewCell (TransformableCell)

- (CFMutableDictionaryRef)xtz_isTransformedDictionary
{
	return [self xtz_isTransformedDictionaryCreateIfNotExist:NO];
}

- (CFMutableDictionaryRef)xtz_isTransformedDictionaryCreateIfNotExist:(BOOL)createIfNeeded
{
	id ret = [self xtz_getAssociatedObjectWithKey:&IS_TRANSFORMED_DICTIONARY_KEY createIfNotExistWithBlock:(createIfNeeded? ^id{
		return CFBridgingRelease(CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks));
	}: NULL)];
	
	NSAssert(ret == nil || [ret isKindOfClass:NSMutableDictionary.class], @"INTERNAL ERROR: Got invalid (not of class NSMutableDictionary) associated object %@ in %@.", ret, NSStringFromSelector(_cmd));
	
	if (ret == nil) return NULL;
	return (CFMutableDictionaryRef)CFAutorelease(CFBridgingRetain(ret));
}

- (BOOL)xtz_isTransformedByExtender:(id <XTZTableViewExtender>)extender
{
	CFMutableDictionaryRef dic = self.xtz_isTransformedDictionary;
	if (dic == NULL) return NO;
	
	/* By convention we remove the key when the object is set as not transformed by the extender.
	 * Thus if the value is non-NULL, we are transformed by the given extender. */
	return (CFDictionaryGetValue(dic, (__bridge const void *)extender) != NULL);
}

- (void)xtz_setTransformed:(BOOL)isTransformed byExtender:(id <XTZTableViewExtender>)extender
{
	CFMutableDictionaryRef dic = [self xtz_isTransformedDictionaryCreateIfNotExist:isTransformed];
	if (dic == NULL) return; /* If set to transformed = YES, dic will never be NULL, else, if dic is NULL, there’s already nothing to do. */
	
	if (isTransformed) CFDictionarySetValue(dic,    (__bridge const void *)extender, CFAutorelease(CFBridgingRetain(@YES)));
	else               CFDictionaryRemoveValue(dic, (__bridge const void *)extender);
}

@end
