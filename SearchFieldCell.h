//
//  SearchFieldCell.h
//  BRSearchField
//
//  Created by Neil Allain on 2/9/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BRSearchFieldCell : NSTextFieldCell {
	NSImage* _image;
	BOOL _backgroundCell;
}

-(void)divideFrame:(NSRect)frame intoImageFrame:(NSRect*)imageFrame textFrame:(NSRect*)cellFrame;

@end
