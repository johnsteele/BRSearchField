//
//  SearchMenuWindow.h
//  BRSearchField
//
//  Created by Neil Allain on 2/10/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BRSearchMenuView;
@class BRSearchField;

@interface BRSearchMenuWindow : NSWindow {
}

-(id)initWithSearchField:(BRSearchField*)searchField;
-(void)popupAt:(NSPoint)location inView:(NSView*)view;
-(void)close;
-(void)resetSize;

@property (readonly) BRSearchMenuView* menuView;

@end
