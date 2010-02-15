//
//  MenuView.m
//  BRSearchField
//
//  Created by Neil Allain on 2/10/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import "SearchMenuView.h"
#import "SearchField.h"
#import "SearchMenuWindow.h"

static const float BRMenuItemYOffset = 4.0;
static const float BRMenuItemXOffset = 4.0;
static const float BRMenuItemXIndent = 10.0;
static const NSInteger BRSearchMenuSearchItem = -1;

#pragma mark -
#pragma mark Private Interface
@interface BRSearchMenuView()
-(NSArray*)menuItemsForTemplateMenuItem:(NSMenuItem *)menuItem;
-(void)recalculateSize;
@property (readonly) BRSearchMenuWindow* menuWindow;
@property (readonly) NSArray* menuItems;
@property (assign) NSMenuItem* highlightedMenuItem;
@property (readonly) NSUInteger highlightedMenuItemIndex;
@end

@implementation BRSearchMenuView

#pragma mark -
#pragma mark Initialization

-(id)init
{
	self = [super init];
	return self;
}

-(id)initWithSearchField:(BRSearchField*)searchField;
{
	self = [self init];
	_searchField = searchField;
	_menuItemAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
		[searchField.searchMenuTemplate font], NSFontAttributeName,
		[NSColor blackColor], NSForegroundColorAttributeName,
		nil];
	_highlightedMenuItemAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
		[searchField.searchMenuTemplate font], NSFontAttributeName,
		[NSColor whiteColor], NSForegroundColorAttributeName,
		nil];
	_disabledMenuItemAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
		[searchField.searchMenuTemplate font], NSFontAttributeName,
		[NSColor grayColor], NSForegroundColorAttributeName,
		nil];
	//[self recalculateSize];
	return self;
}

-(void)dealloc
{
	[_menuItemAttributes release], _menuItemAttributes = nil;
	[_disabledMenuItemAttributes release], _disabledMenuItemAttributes = nil;
	[_highlightedMenuItemAttributes release], _highlightedMenuItemAttributes = nil;
	[_menuItems release], _menuItems = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

-(NSSize)menuSize
{
	if (!_menuItems) {
		[self recalculateSize];
	}
	return _menuSize;
}

#pragma mark -
#pragma mark Public methods

-(void)clearMenuSelection
{
	_highlightedMenuItem = nil;
	[self setNeedsDisplay:YES];
}

-(BOOL)sendMenuAction
{
	BOOL actionSent = NO;
	id target = [self.highlightedMenuItem target];
	SEL action = [self.highlightedMenuItem action];
	if (target && action) {
		[target performSelector:action withObject:self.highlightedMenuItem];
		actionSent = YES;
	}
	return actionSent;
}

-(void)markMenuAsDirty
{
	[_menuItems release], _menuItems = nil;
}

-(void)selectNext
{
	NSUInteger currentIndex = self.highlightedMenuItemIndex;
	NSUInteger index = currentIndex + 1;
	if (currentIndex == NSNotFound) {
		index = 0;
	}
	while ((index < [self.menuItems count]) &&
		![[self.menuItems objectAtIndex:index] isEnabled]) {
		++index;
	}
	if (index < [self.menuItems count]) {
		self.highlightedMenuItem = [self.menuItems objectAtIndex:index];
	}
}

-(void)selectPrevious
{
	NSUInteger currentIndex = self.highlightedMenuItemIndex;
	NSUInteger index = currentIndex - 1;
	if (currentIndex == NSNotFound) {
		return;
	}
	while ((index >= 0) && (index < [self.menuItems count]) &&
		   ![[self.menuItems objectAtIndex:index] isEnabled]) {
		--index;
	}
	if ((index < [self.menuItems count]) && (index >= 0)) {
		self.highlightedMenuItem = [self.menuItems objectAtIndex:index];
	} else {
		self.highlightedMenuItem = nil;
	}
}

#pragma mark -
#pragma mark NSView overrides

-(void)drawRect:(NSRect)dirtyRect
{
	NSRect bounds = [self bounds];
	CGFloat yPosition = BRMenuItemYOffset;
	CGFloat width = bounds.size.width;
	for (NSMenuItem* menuItem in self.menuItems) {
		CGFloat indent = [menuItem indentationLevel] * BRMenuItemXIndent;
		NSString* title = [menuItem title];
		NSRect menuItemFrame = NSMakeRect(
			BRMenuItemXOffset + indent,
			yPosition,
			width,
			_menuItemHeight);
		if ([menuItem isSeparatorItem]) {
			[[NSColor grayColor] setStroke];
			NSInteger integralLineYPosition = (NSInteger)(yPosition + (_menuItemHeight/2.0));
			NSPoint startPoint = NSMakePoint(1.0, integralLineYPosition + 0.5);
			NSPoint endPoint = NSMakePoint(width-1.0, startPoint.y);
			[NSBezierPath setDefaultLineWidth:0.25];
			[NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
		} else {
			NSDictionary* attributes;
			if (_highlightedMenuItem == menuItem) {
				attributes = _highlightedMenuItemAttributes;
				[[NSColor selectedMenuItemColor] setFill];
				NSRect selectionFrame = menuItemFrame;
				selectionFrame.origin.x = 0.0;
				[NSBezierPath fillRect:selectionFrame];
			} else {
				attributes = [menuItem isEnabled] ? _menuItemAttributes : _disabledMenuItemAttributes;
			}
				
			[title drawInRect:menuItemFrame withAttributes:attributes];
		}
		yPosition += BRMenuItemYOffset + _menuItemHeight;
	}
}

-(BOOL)isFlipped
{
	return YES;
}

-(void)mouseEntered:(NSEvent *)theEvent
{
	id trackedObject = (NSObject*)[theEvent userData];
	if ([trackedObject isKindOfClass:[NSDictionary class]]) {
		NSMenuItem* menuItem = [trackedObject objectForKey:@"menuItem"];
		if ([menuItem isEnabled]) {
			self.highlightedMenuItem = menuItem;
		}
	}
}

-(void)mouseExited:(NSEvent *)theEvent
{
	NSObject* trackedObject = (NSObject*)[theEvent userData];
	if (trackedObject == self) {
		self.highlightedMenuItem = nil;
	}
}

-(void)mouseUp:(NSEvent *)theEvent
{
	NSPoint viewPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	for(NSTrackingArea* trackingArea in [self trackingAreas]) {
		if (NSPointInRect(viewPoint, [trackingArea rect])) {
			NSMenuItem* menuItem = [[trackingArea userInfo] objectForKey:@"menuItem"];
			if ([menuItem isEnabled]) {
				[_searchField sendAction];
			}
		}
	}
}

-(void)updateTrackingAreas
{
	[self recalculateSize];
}
#pragma mark -
#pragma mark Private Methods

-(void)recalculateSize
{
	NSUInteger itemCount = 0;
	_menuItemHeight = 0.0;
	_menuSize.width = 0.0;
	_highlightedMenuItem = nil;
	
	for (NSTrackingArea* trackingArea in [self trackingAreas]) {
		[self removeTrackingArea:trackingArea];
	}
	for (NSMenuItem* menuItem in self.menuItems) {
		NSSize textSize = [[menuItem title] sizeWithAttributes:_menuItemAttributes];
		textSize.width += [menuItem indentationLevel] * BRMenuItemXIndent;
		_menuItemHeight = textSize.height > _menuItemHeight ? textSize.height : _menuItemHeight;
		_menuSize.width = textSize.width > _menuSize.width ? textSize.width : _menuSize.width;
		++itemCount;
	}
	_menuSize.width += 2 * BRMenuItemXOffset;
	_menuSize.height = ((_menuItemHeight + BRMenuItemYOffset) * itemCount) + BRMenuItemYOffset;
	
	NSRect trackingRect = NSMakeRect(0.0, 0.0, _menuSize.width, _menuItemHeight + BRMenuItemYOffset);
	for (NSMenuItem* menuItem in self.menuItems) {
		NSDictionary* userInfo = [NSDictionary dictionaryWithObject:menuItem forKey:@"menuItem"];
		NSTrackingArea* trackingArea = [[[NSTrackingArea alloc] 
			initWithRect:trackingRect 
			options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp | NSTrackingEnabledDuringMouseDrag
			owner:self 
			userInfo:userInfo] autorelease];
		[self addTrackingArea:trackingArea];
		trackingRect.origin.y += _menuItemHeight + BRMenuItemYOffset;
	}
	NSRect viewTrackingRect = NSMakeRect(0.0, 0.0, _menuSize.width, _menuSize.height);
	[self addTrackingRect:viewTrackingRect owner:self userData:self assumeInside:NO];
	[self.menuWindow resetSize];
}

-(BRSearchMenuWindow*)menuWindow
{
	return (BRSearchMenuWindow*)[self window];
}

-(NSArray*)menuItems
{
	if (_menuItems == nil) {
		NSMutableArray* items = [NSMutableArray array];
		for (NSMenuItem* menuItem in [_searchField.searchMenuTemplate itemArray]) {
			[items addObjectsFromArray:[self menuItemsForTemplateMenuItem:menuItem]];
		}
		_menuItems = [items copy];
	}
	return _menuItems;
}


-(NSArray*)menuItemsForTemplateMenuItem:(NSMenuItem*)menuItem
{
	NSArray* menuItems = nil;
	if ([menuItem tag] != 0) {
		NSArray* titles  = [_searchField.searchMenuDelegate searchField:_searchField valuesForTag:[menuItem tag]];
		if (titles) {
			NSMutableArray* mutableItems = [NSMutableArray array];
			if ([titles count] > 0) {
				// convert the titles to menu items
				for (NSString* title in titles) {
					NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
					[item setTitle:title];
					[item setTag:BRSearchMenuSearchItem];
					[item setIndentationLevel:[menuItem indentationLevel]];
					[mutableItems addObject:item];
				}
			} else if ([_searchField.searchMenuDelegate respondsToSelector:@selector(searchField:placeholderForTag:)]) {
				NSString* placeholder = [_searchField.searchMenuDelegate searchField:_searchField placeholderForTag:[menuItem tag]];
				if (placeholder) {
					// use the placeholder
					NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
					[item setTitle:placeholder];
					[item setEnabled:NO];
					[item setIndentationLevel:[menuItem indentationLevel]];
					[mutableItems addObject:item];
				}
			}
			menuItems = mutableItems;
		}
	}
	if (!menuItems) {
		menuItems = [NSArray arrayWithObject:menuItem];
	}
	return menuItems;
}

-(NSMenuItem*)highlightedMenuItem
{
	return _highlightedMenuItem;
}

-(void)setHighlightedMenuItem:(NSMenuItem*)menuItem
{
	if (menuItem != _highlightedMenuItem) {
		if (menuItem) {
			if ([menuItem isEnabled]) {
				_highlightedMenuItem = menuItem;
				if ([menuItem tag] == BRSearchMenuSearchItem) {
					[_searchField setFieldValueFromMenu:[_highlightedMenuItem title]];
				} else {
					[_searchField setFieldValueFromMenu:nil];
				}
				[self setNeedsDisplay:YES];
			}
		} else {
			_highlightedMenuItem = nil;
			[_searchField setFieldValueFromMenu:nil];
			[self setNeedsDisplay:YES];
		}
	}
}

-(NSUInteger)highlightedMenuItemIndex
{
	return [self.menuItems indexOfObject:self.highlightedMenuItem];
}
@end
