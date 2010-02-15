//
//  BRSearchFieldAppDelegate.m
//  BRSearchField
//
//  Created by Neil Allain on 2/9/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import "BRSearchFieldAppDelegate.h"

@implementation BRSearchFieldAppDelegate

-(void)awakeFromNib
{
	self.recentSearches = [NSMutableArray array];
	self.searchableValues = [NSArray arrayWithObjects:
		@"done", @"donuts", @"doe, a deer", nil];

	NSAssert(self.searchField != nil, @"searchField outlet not set");
	self.searchField.searchFieldDataSource = self;
	NSMenu* menu = [[[NSMenu alloc] init] autorelease];
	[menu setFont:[NSFont menuFontOfSize:12.0]];

	NSMenuItem* recent = [[[NSMenuItem alloc] init] autorelease];
	[recent setTitle:@"Recent"];
	[recent setEnabled:NO];
	[menu addItem:recent];
	NSMenuItem* recentItems = [[[NSMenuItem alloc] init] autorelease];
	[recentItems setTag:1000];
	[recentItems setIndentationLevel:1];
	[menu addItem:recentItems];

	[menu addItem:[NSMenuItem separatorItem]];
	
	 NSMenuItem* suggestions = [[[NSMenuItem alloc] init] autorelease];
	 [suggestions setTitle:@"Suggestions"];
	 [suggestions setEnabled:NO];
	 [menu addItem:suggestions];
	 NSMenuItem* suggestionItems = [[[NSMenuItem alloc] init] autorelease];
	 [suggestionItems setTag:1001];
	 [suggestionItems setIndentationLevel:1];
	 [menu addItem:suggestionItems];
	 
	 [menu addItem:[NSMenuItem separatorItem]];
	 NSMenuItem* clear = [[[NSMenuItem alloc] init] autorelease];
	 [clear setTitle:@"Clear Recent"];
	 [clear setTarget:self];
	 [clear setAction:@selector(clearRecent:)];
	 [menu addItem:clear];
	 
	 self.searchField.searchMenuTemplate = menu;
}

-(void)dealloc
{
	[_recentSearches release], _recentSearches = nil;
	[_searchableValues release], _searchableValues = nil;
	[_itemToAdd release], _itemToAdd = nil;
	[super dealloc];
}

@synthesize window;
@synthesize searchField = _searchField;
@synthesize recentSearches = _recentSearches;
@synthesize searchableValues = _searchableValues;
@synthesize itemToAdd = _itemToAdd;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

-(NSArray*)searchField:(BRSearchField*)searchField valuesForTag:(NSInteger)tag
{
	if (tag == 1000) {
		return self.recentSearches;
	} else if (tag == 1001) {
		NSMutableArray* matches = [NSMutableArray array];
		NSString* searchValue = [[searchField stringValue] lowercaseString];
		NSLog(@"+++++finding matches for: %@", searchValue);
		for(NSString* item in self.searchableValues) {
			if ([item hasPrefix:searchValue]) {
				[matches addObject:item];
			}
		}
		return matches;
	}
	return nil;
}

-(NSString*)searchField:(BRSearchField *)searchField placeholderForTag:(NSInteger)tag
{
	if (tag == 1001) {
		return @"No Matches Found";
	}
	return nil;
}

-(IBAction)runSearch:(id)sender
{
	NSString* searchValue = [self.searchField stringValue];
	NSLog(@"+++++run search on value: %@", [self.searchField stringValue]);
	[self.recentSearches insertObject:searchValue atIndex:0];
	if ([self.recentSearches count] > 5) {
		[self.recentSearches removeLastObject];
	}
	[self.window makeFirstResponder:self.window];
}

-(IBAction)addItem:(id)sender
{
	[self.window makeFirstResponder:self.window];
	if ([self.itemToAdd length] > 0) {
		NSLog(@"adding item: %@", self.itemToAdd);
		[[self mutableArrayValueForKey:@"searchableValues"] addObject:self.itemToAdd];
		self.itemToAdd = @"";
	}
}

-(IBAction)clearRecent:(id)sender
{
	NSLog(@"+++++clear recent searches");
	[self.recentSearches removeAllObjects];
}

@end
