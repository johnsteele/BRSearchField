//
//  SearchFieldTextView.h
//  BRSearchField
//
//  Created by Neil Allain on 2/13/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BRSearchField;

@interface BRSearchFieldTextView : NSTextView {
	BRSearchField* _searchField;	
}

@property (assign) BRSearchField* searchField;

-(void)superMoveUp:(id)sender;
-(void)superMoveDown:(id)sender;

@end
