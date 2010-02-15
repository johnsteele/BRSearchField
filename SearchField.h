//
//  SearchField.h
//  BRSearchField
//
//  Created by Neil Allain on 2/9/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BRSearchMenuWindow;
@class BRSearchField;
@class BRSearchFieldTextView;

@protocol BRSearchFieldDataSource<NSObject>
// return an array of strings that should replace the menu item with the given tag
// or nil if no replacment should be made.
-(NSArray*)searchField:(BRSearchField*)searchField valuesForTag:(NSInteger)tag;
@optional
// return the title for a disabled item that should be used when the values for the
// tag is an empty array.
-(NSString*)searchField:(BRSearchField*)searchField placeholderForTag:(NSInteger)tag;
@end

@interface BRSearchField : NSTextField {
	NSMenu* _searchMenuTemplate;
	BRSearchMenuWindow* _menuWindow;
	id<BRSearchFieldDataSource> _searchFieldDataSource;
	NSString* _typedFieldValue;
	BOOL _menuChangingFieldValue;
	BOOL _protectOpenMenu;
	NSTimeInterval _timeOfLastMenuToggle;
	BRSearchFieldTextView* _fieldEditor;
	BOOL _handleMenuHighlight;
}

@property (assign) IBOutlet id<BRSearchFieldDataSource> searchFieldDataSource;
@property (retain) IBOutlet NSMenu* searchMenuTemplate;
@property (readonly) BRSearchFieldTextView* fieldEditor;

-(void)setFieldValueFromMenu:(NSString*)fieldValue;

-(void)fieldEditorMoveUp:(id)sender;
-(void)fieldEditorMoveDown:(id)sender;
-(void)fieldEditorInsertNewline:(id)sender;
-(void)openMenu;
-(void)closeMenu;
-(BOOL)toggleMenu;
-(void)sendAction;
@end
