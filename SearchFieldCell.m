//
//  SearchFieldCell.m
//  BRSearchField
//
//  Created by Neil Allain on 2/9/10.
//  Copyright 2010 Blue Rope Software. All rights reserved.
//

#import "SearchFieldCell.h"
#import "SearchField.h"
#import "SearchFieldTextView.h"

#pragma mark -
#pragma mark Private Interface
@interface BRSearchFieldCell()
@property (readonly) NSImage* image;
@end

@implementation BRSearchFieldCell

#define kIconImageSize		18.0

#define kImageOriginXOffset 4
#define kImageOriginYOffset 1

#define kTextOriginXOffset	2
#define kTextOriginYOffset	2
#define kTextHeightAdjust	4

-(void)dealloc
{
	[_image release], _image = nil;
	[super dealloc];
}

-(id)copyWithZone:(NSZone *)zone
{
	BRSearchFieldCell* copy = [super copyWithZone:zone];
	[copy->_image retain];
	return copy;
}

-(void)divideFrame:(NSRect)frame intoImageFrame:(NSRect*)imageFrame textFrame:(NSRect*)textFrame
{
	NSImage* image = self.image;
	NSSize imageSize = [image size];
	
	NSDivideRect(frame, imageFrame, textFrame, 3 + imageSize.width, NSMinXEdge);
	
	imageFrame->origin.x += kImageOriginXOffset;
	imageFrame->origin.y -= kImageOriginYOffset;
	imageFrame->size = imageSize;
	
	imageFrame->origin.y += ceil((textFrame->size.height - imageFrame->size.height) / 2);
	
	textFrame->origin.x += kTextOriginXOffset;
	textFrame->origin.y += kTextOriginYOffset;
	textFrame->size.height -= kTextHeightAdjust;
}

- (NSImage*)image
{
	if (!_image) {
		_image = [[NSImage imageNamed:@"SearchIcon"] retain];
	}
	return _image;
}


// -------------------------------------------------------------------------------
//	titleRectForBounds:cellRect
//
//	Returns the proper bound for the cell's title while being edited
// -------------------------------------------------------------------------------
- (NSRect)titleRectForBounds:(NSRect)cellRect
{	
	NSRect imageFrame;
	NSRect textFrame;
	[self divideFrame:cellRect intoImageFrame:&imageFrame textFrame:&textFrame];
	return textFrame;
}

// -------------------------------------------------------------------------------
//	editWithFrame:inView:editor:delegate:event
// -------------------------------------------------------------------------------
- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

// -------------------------------------------------------------------------------
//	selectWithFrame:inView:editor:delegate:event:start:length
// -------------------------------------------------------------------------------
- (void)selectWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

// -------------------------------------------------------------------------------
//	drawWithFrame:cellFrame:controlView:
// -------------------------------------------------------------------------------
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	NSRect fullFrame = cellFrame;
	if (_backgroundCell) {
		// makes sure the cells background is properly draw
		[super drawWithFrame:fullFrame inView:controlView];
	} else {
		// copy the cell, set the background flag and draw.
		BRSearchFieldCell* backgroundCell = [[self copy] autorelease];
		backgroundCell->_backgroundCell = YES;
		[backgroundCell setStringValue:@""];
		[backgroundCell drawWithFrame:fullFrame inView:controlView];

		// now we'll draw the content of the cell (image & text)
		NSImage* image = self.image;
		NSRect imageFrame;
		NSRect textFrame;
		[self divideFrame:cellFrame intoImageFrame:&imageFrame textFrame:&textFrame];

		if ([controlView isFlipped]) {
			imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2) - 2.0;
		} else {
			imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2) + 2.0;
		}
		[image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
		// offset for text field border
		textFrame.origin.y += 1.0;
		textFrame.origin.x += 11.0;
		NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
			[self textColor],NSForegroundColorAttributeName,
			[self font], NSFontAttributeName,
			nil];
		[[self stringValue] drawInRect:textFrame withAttributes:attrs];
	}
}

// -------------------------------------------------------------------------------
//	cellSize:
// -------------------------------------------------------------------------------
- (NSSize)cellSize
{
	NSImage* image = self.image;
    NSSize cellSize = [super cellSize];
    cellSize.width += (image ? [image size].width : 0) + 3;
    return cellSize;
}

-(NSTextView*)fieldEditorForView:(NSView *)aControlView
{
	if ([aControlView isKindOfClass:[BRSearchField class]]) {
		BRSearchField* searchField = (BRSearchField*)aControlView;
		return searchField.fieldEditor;
	}
	return nil;
}

@end
