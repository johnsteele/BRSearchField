//
//  SearchMenuWindow.m
//  BRSearchField
//
//  Created by Neil Allain on 2/10/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import "SearchMenuWindow.h"
#import "SearchMenuView.h"

#pragma mark -
#pragma mark Private Interface
@interface BRSearchMenuWindow()
-(NSColor*)roundedRectBackgroundColor;
@end

@implementation BRSearchMenuWindow

#pragma mark -
#pragma mark Initialization

-(id)initWithSearchField:(BRSearchField*)searchField;
{
	BRSearchMenuView* menuView = [[BRSearchMenuView alloc] initWithSearchField:searchField];
	self = [super initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	[self setBackgroundColor:[NSColor whiteColor]];
	[self setMovableByWindowBackground:NO];
	[self setExcludedFromWindowsMenu:YES];
	[self setAlphaValue:1.0];
	[self setOpaque:NO];
	[self setHasShadow:YES];
	[self useOptimizedDrawing:YES];
	
	[self setAcceptsMouseMovedEvents:YES];
	
	[self setContentView:menuView];
	[menuView setFrame:NSZeroRect];
	[menuView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	return self;
}

#pragma mark -
#pragma mark Properties

-(BRSearchMenuView*)menuView
{
	return (BRSearchMenuView*)[self contentView];
}

#pragma mark -
#pragma mark Public methods

-(void)popupAt:(NSPoint)location inView:(NSView *)view
{
	if ([self parentWindow] == nil) {
		[self resetSize];
		NSWindow* parentWindow = [view window];
		BRSearchMenuView* menuView = (BRSearchMenuView*)[self contentView];
		[menuView clearMenuSelection];
		NSPoint windowLocation = [view convertPoint:location toView:nil];
		NSRect contentRect;
		contentRect.origin = [parentWindow convertBaseToScreen:windowLocation];
		contentRect.size = menuView.menuSize;
		contentRect.origin.y -= contentRect.size.height;
		[self setFrame:contentRect display:NO];
		[parentWindow addChildWindow:self ordered:NSWindowAbove];
	}
}

-(void)close
{
	if ([self parentWindow]) {
		NSWindow* parentWindow = [self parentWindow];
		[parentWindow removeChildWindow:self];
		[self orderOut:self];
	}
}

-(void)resetSize
{
	NSRect frame = [self frame];
	NSSize newSize = self.menuView.menuSize;
	CGFloat heightChange = newSize.height - frame.size.height;
	frame.origin.y -= heightChange;
	frame.size = self.menuView.menuSize;
	[self setFrame:frame display:YES];
	[self setBackgroundColor:[self roundedRectBackgroundColor]];
}


#pragma mark -
#pragma mark Private methods
-(NSColor*)roundedRectBackgroundColor
{
	NSRect frame = [self frame];
	NSImage* bgImage = [[[NSImage alloc] initWithSize:frame.size] autorelease];
	NSRect bounds = frame;
	bounds.origin = NSZeroPoint;
	
	[bgImage lockFocus];
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:5 yRadius:5];
	[[NSColor whiteColor] set];
	[path fill];
	[bgImage unlockFocus];
	return [NSColor colorWithPatternImage:bgImage];
}
@end
