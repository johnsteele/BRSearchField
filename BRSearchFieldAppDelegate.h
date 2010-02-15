//
//  BRSearchFieldAppDelegate.h
//  BRSearchField
//
//  Created by Neil Allain on 2/9/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SearchField.h"

@interface BRSearchFieldAppDelegate : NSObject <NSApplicationDelegate, BRSearchFieldDelegate> {
    NSWindow *window;
	BRSearchField* _searchField;
	NSMutableArray* _recentSearches;
	NSArray* _searchableValues;
	NSString* _itemToAdd;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet BRSearchField* searchField;

@property (retain) NSArray* searchableValues;
@property (retain) NSMutableArray* recentSearches;
@property (retain) NSString* itemToAdd;

-(IBAction)runSearch:(id)sender;
-(IBAction)addItem:(id)sender;
@end
