//
//  SearchField.m
//  BRSearchField
//
//  Created by Neil Allain on 2/9/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import "SearchField.h"
#import "SearchMenuWindow.h"
#import "SearchMenuView.h"
#import "SearchFieldCell.h"
#import "SearchFieldTextView.h"

static const CGFloat BRSearchMenuYOffset = 25.0;

#pragma mark -
#pragma mark Private Interface
@interface BRSearchField()
@property (readonly) BRSearchMenuWindow* menuWindow;
@property (copy) NSString* typedFieldValue;
@property (readonly) BRSearchFieldCell* searchFieldCell;
@property (readonly) BOOL isMenuOpen;
-(void)rebuildMenu;
@end

@implementation BRSearchField
#pragma mark -
#pragma mark Initialization

-(void)awakeFromNib
{
	[super awakeFromNib];
	NSAssert([[self cell] isKindOfClass:[BRSearchFieldCell class]], @"BRSearchField must use a BRSearchFieldCell");
}

-(void)dealloc
{
	[_fieldEditor release], _fieldEditor = nil;
	[_menuWindow release], _menuWindow = nil;
	[_searchMenuTemplate release], _searchMenuTemplate = nil;
	[_typedFieldValue release], _typedFieldValue = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize searchMenuTemplate = _searchMenuTemplate;
@synthesize searchMenuDelegate = _searchMenuDelegate;

-(void)setSearchMenuDelegate:(id<BRSearchFieldDelegate>)searchMenuDelegate
{
	_searchMenuDelegate = searchMenuDelegate;
	if (_menuWindow != nil) {
		[_menuWindow.menuView markMenuAsDirty];
	}
}

-(void)setSearchMenuTemplate:(NSMenu *)searchMenuTemplate
{
	[_searchMenuTemplate autorelease];
	_searchMenuTemplate = [searchMenuTemplate retain];
	if (_menuWindow != nil) {
		[_menuWindow.menuView markMenuAsDirty];
	}
}

-(NSTextView*)fieldEditor
{
	if (_fieldEditor == nil) {
		_fieldEditor = [[BRSearchFieldTextView alloc] init];
		[_fieldEditor setFieldEditor:YES];
		_fieldEditor.searchField = self;
	}
	return _fieldEditor;
}

#pragma mark -
#pragma mark Public methods

-(void)setFieldValueFromMenu:(NSString *)fieldValue
{
	_menuChangingFieldValue = YES;
	NSText* textEditor = [[self window] fieldEditor:YES forObject:self];
	NSRange selection;
	if (fieldValue) {
		[self setStringValue:fieldValue];
		
		// set up the selection
		NSString* lowerField = [fieldValue lowercaseString];
		NSString* lowerTyped = [self.typedFieldValue lowercaseString];
		if (lowerTyped && [lowerField hasPrefix:lowerTyped]) {
			selection.location = [lowerTyped length];
			selection.length = [fieldValue length] - [lowerTyped length];
		} else {
			selection.location = 0;
			selection.length = [fieldValue length];
		}
	} else {
		[self setStringValue:self.typedFieldValue ? self.typedFieldValue : @""];
		selection.location = [self.typedFieldValue length];
		selection.length = 0;
	}
	[textEditor setSelectedRange:selection];
	_menuChangingFieldValue = NO;
}

-(void)closeMenu
{
	if (!_protectOpenMenu) {
		if (self.isMenuOpen) {
			[self.menuWindow close];
			_timeOfLastMenuToggle = [NSDate timeIntervalSinceReferenceDate];
		}
	}
}
-(void)openMenu
{
	if (!self.isMenuOpen) {
		NSPoint menuLocation = NSMakePoint(0.0, BRSearchMenuYOffset);
		[self.menuWindow popupAt:menuLocation inView:self];
		_timeOfLastMenuToggle = [NSDate timeIntervalSinceReferenceDate];
	}
}

-(BOOL)toggleMenu
{
	BOOL opened = NO;
	// a hack, but clicking on the search button first causes a resignFirstResponder
	// which will close the menu, then it would be toggled back open because of the click.
	// To get around this, it'll just disallow rapid toggling
	if (([NSDate timeIntervalSinceReferenceDate] - _timeOfLastMenuToggle) > 0.01) {
		if (self.isMenuOpen) {
			[self closeMenu];
		} else {
			[self openMenu];
			opened = YES;
		}
	}
	return opened;
	
}

-(void)sendAction
{
	if (self.isMenuOpen) {
		[self closeMenu];
		if (![self.menuWindow.menuView sendMenuAction]) {
			[self sendAction:[self action] to:[self target]];
		}
	} else {
		[self sendAction:[self action] to:[self target]];
	}
	self.typedFieldValue = nil;
	[self rebuildMenu];
}

#pragma mark -
#pragma mark NSTextField overrides
-(void)textDidChange:(NSNotification *)notification
{
	NSString* newValue = [self stringValue];
	if (!_menuChangingFieldValue) {
		if (([newValue length] > 0) && 
			([self.typedFieldValue length] < [newValue length])){
			[self rebuildMenu];
			[self openMenu];
		} else {
			[self closeMenu];
		}
		self.typedFieldValue = newValue;
	} else {
		//NSLog(@"value change from menu:\n%@", notification);
	}
	[super textDidChange:notification];
}

-(void)fieldEditorMoveUp:(id)sender
{
	if (self.isMenuOpen) {
		[self.menuWindow.menuView selectPrevious];
	} else {
		[self.fieldEditor superMoveUp:sender];
	}
}

-(void)fieldEditorMoveDown:(id)sender
{
	if (self.isMenuOpen) {
		[self.menuWindow.menuView selectNext];
	} else {
		[self.fieldEditor superMoveDown:sender];
	}
}

-(void)fieldEditorInsertNewline:(id)sender
{
	[self sendAction];
}

#pragma mark -
#pragma mark NSTextField overrides

-(void)selectText:(id)sender
{
	_protectOpenMenu = YES;
	[super selectText:sender];
	_protectOpenMenu = NO;
}

-(void)mouseDown:(NSEvent *)theEvent
{
	NSRect bounds = [self bounds];
	NSRect textFrame;
	NSRect imageFrame;
	[self.searchFieldCell divideFrame:bounds intoImageFrame:&imageFrame textFrame:&textFrame];
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if (NSPointInRect(point, imageFrame)) {
		_handleMenuHighlight = [self toggleMenu];
	} else {
		[super mouseDown:theEvent];
	}
}

-(void)mouseUp:(NSEvent *)theEvent
{
	if (_handleMenuHighlight && [self isMenuOpen]) {
		NSPoint screenPoint = [[self window] convertBaseToScreen:[theEvent locationInWindow]];
		if (NSPointInRect(screenPoint, [self.menuWindow frame])) {
			[self sendAction];
//			[self closeMenu];
//			if (![self.menuWindow.menuView sendMenuAction]) {
//				[self sendAction:[self action] to:[self target]];
//			}
		}
	}
	_handleMenuHighlight = NO;
	[super mouseUp:theEvent];
}

-(void)resetCursorRects
{
	NSRect bounds = [self bounds];
	NSRect textFrame;
	NSRect imageFrame;
	[self.searchFieldCell divideFrame:bounds intoImageFrame:&imageFrame textFrame:&textFrame];
	[self addCursorRect:textFrame cursor:[NSCursor IBeamCursor]];
}

-(void)textDidEndEditing:(NSNotification *)notification
{
	SEL saveAction = [self action];
	[self setAction:NULL];
	[super textDidEndEditing:notification];
	[self setAction:saveAction];
	//[self closeMenu];
}

-(BOOL)resignFirstResponder
{
	BOOL resigned = [super resignFirstResponder];
	if (resigned) {
		[self closeMenu];
	}
	return resigned;
}

#pragma mark -
#pragma mark Private methods

@synthesize typedFieldValue = _typedFieldValue;

-(BRSearchMenuWindow*)menuWindow {
	if (!_menuWindow) {
		_menuWindow = [[BRSearchMenuWindow alloc] initWithSearchField:self];
	}
	return _menuWindow;
}

-(BRSearchFieldCell*)searchFieldCell
{
	return (BRSearchFieldCell*)[self cell];
}

-(BOOL)isMenuOpen
{
	return [self.menuWindow parentWindow] != nil;
}

-(void)rebuildMenu
{
	[self.menuWindow.menuView markMenuAsDirty];
	[self.menuWindow.menuView setNeedsDisplay:YES];
	[self.menuWindow resetSize];
}
@end
