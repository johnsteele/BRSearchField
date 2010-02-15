//
//  SearchFieldTextView.m
//  BRSearchField
//
//  Created by Neil Allain on 2/13/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import "SearchFieldTextView.h"
#import "SearchField.h"

@implementation BRSearchFieldTextView

@synthesize searchField = _searchField;

-(void)moveUp:(id)sender
{
	[self.searchField fieldEditorMoveUp:sender];
}

-(void)moveDown:(id)sender
{
	[self.searchField fieldEditorMoveDown:sender];
}

-(void)insertNewline:(id)sender
{
	[super insertNewline:sender];
	[self.searchField fieldEditorInsertNewline:sender];
}

-(BOOL)resignFirstResponder
{
	[self.searchField closeMenu];
	return [super resignFirstResponder];
}

-(void)superMoveUp:(id)sender
{
	[super moveUp:sender];
}

-(void)superMoveDown:(id)sender
{
	[super moveDown:sender];
}

@end
