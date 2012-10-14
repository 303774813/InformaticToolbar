//
//  UIViewController+InformaticToolbar.m
//  InformaticToolbar
//
//  Created by Greg Wang on 12-10-13.
//  Copyright (c) 2012年 Greg Wang. All rights reserved.
//

#import "UIViewController+InformaticToolbar.h"
#import "objc/runtime.h"

static NSString * const ITBarItemSets = @"ITBarItemSets";
static NSString * const ITVisibleBarItemSet = @"ITVisibleBarItemSet";

@implementation UIViewController (InformaticToolbar)

- (NSArray *)barItemSets
{
	return [self getBarItemSets];
}

- (NSMutableArray *)getBarItemSets
{
	NSMutableArray *barItemSets = objc_getAssociatedObject(self, (__bridge const void *)(ITBarItemSets));
	if (barItemSets == nil) {
		barItemSets = [[NSMutableArray alloc] init];
		[self setBarItemSets:barItemSets];
	}
	return barItemSets;
}

- (void)setBarItemSets:(NSMutableArray *)barItemSets
{
	objc_setAssociatedObject(self, (__bridge const void *)(ITBarItemSets), nil, OBJC_ASSOCIATION_RETAIN);
	objc_setAssociatedObject(self, (__bridge const void *)(ITBarItemSets), barItemSets, OBJC_ASSOCIATION_RETAIN);
}

- (ITBarItemSet *)visibleBarItemSet
{
	return objc_getAssociatedObject(self, (__bridge const void *)(ITVisibleBarItemSet));
}

- (void)setVisibleBarItemSet:(ITBarItemSet *)visibleBarItemSet animated:(BOOL)animated
{
	// deassociate old object
	objc_setAssociatedObject(self, (__bridge const void *)(ITVisibleBarItemSet), nil, OBJC_ASSOCIATION_ASSIGN);
	
	if (visibleBarItemSet == nil) {
		[self.navigationController setToolbarHidden:YES animated:animated];
		[self setToolbarItems:@[] animated:animated];
		return;
	}
	
	// Construct the toolbar
	NSMutableArray *toolbarItems = [visibleBarItemSet.barItems mutableCopy];
	[toolbarItems insertObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] atIndex:0];
	[toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
	
	// If is dismissable
	if (visibleBarItemSet.dismissTarget != nil && [visibleBarItemSet.dismissTarget respondsToSelector:visibleBarItemSet.dismissAction]) {
		[toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:visibleBarItemSet action:@selector(dismiss:)]];
	}
	
	// Associate the object
	objc_setAssociatedObject(self, (__bridge const void *)(ITVisibleBarItemSet), visibleBarItemSet, OBJC_ASSOCIATION_ASSIGN);
	
	// Present the toolbar and items
	[self.navigationController setToolbarHidden:NO animated:animated];
	[self setToolbarItems:toolbarItems animated:animated];
}

#pragma mark - methods

- (void)pushBarItemSet:(ITBarItemSet *)barItemSet animated:(BOOL)animated;
{
	if (![self.barItemSets containsObject:barItemSet]) {
		[self appendBarItemSet:barItemSet];
	}
	
	// Set as visible bar item set
	[self setVisibleBarItemSet:barItemSet animated:animated];
}

- (void)appendBarItemSet:(ITBarItemSet *)barItemSet
{
	[[self getBarItemSets] addObject:barItemSet];
}

- (void)removeBarItemSet:(ITBarItemSet *)barItemSet animated:(BOOL)animated
{
	NSUInteger index = [self.barItemSets indexOfObject:barItemSet];
	[[self getBarItemSets] removeObject:barItemSet];
	
	if (self.visibleBarItemSet == barItemSet) {
		NSUInteger count = [self.barItemSets count];
		barItemSet = count == 0 ? nil : index >= count ? [self.barItemSets objectAtIndex:index - 1] : [self.barItemSets objectAtIndex:index];
		
		[self setVisibleBarItemSet:barItemSet animated:animated];
	}
}

- (void)removeAllBarItemSetsAnimated:(BOOL)animated
{
	[[self getBarItemSets] removeAllObjects];
	[self setVisibleBarItemSet:nil animated:animated];
}

@end
