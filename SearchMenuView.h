//
//  SearchMenuView.h
//  BRSearchField
//
//  Created by Neil Allain on 2/10/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BRSearchField;

@interface BRSearchMenuView : NSView {
	BRSearchField* _searchField;
	NSArray* _menuItems;
	NSDictionary* _menuItemAttributes;
	NSDictionary* _disabledMenuItemAttributes;
	NSDictionary* _highlightedMenuItemAttributes;
	CGFloat _menuItemHeight;
	NSSize _menuSize;
	NSMenuItem* _highlightedMenuItem;
}

-(id)initWithSearchField:(BRSearchField*)searchField;

@property (readonly) NSSize menuSize;

-(void)clearMenuSelection;
-(BOOL)sendMenuAction;
-(void)markMenuAsDirty;
-(void)selectNext;
-(void)selectPrevious;

@end
