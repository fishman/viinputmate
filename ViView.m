//
//  ViView.m
//  ViMate
//
//  Created by Rodrigue Cloutier on 18/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViView.h"


@implementation ViView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setCaretColor: [[NSColor grayColor] colorWithAlphaComponent:0.5]];
    }
    return self;
}

- (void)dealloc
{
	[caretColor release];
	[super dealloc];
}

- (BOOL)isFlipped
{
	return TRUE;
}

- (void)setCaretColor:(NSColor*)color
{
	[caretColor release];
	caretColor = color;
	[caretColor retain];
}

- (void)setMode:(ViMode)theMode
{
	mode = theMode;
	[self setNeedsDisplay:TRUE];

    id oakTextView = [self superview];
	NSDictionary * stylesForCaret = [oakTextView stylesForCaret];
	NSColor * newColor = [NSColor colorFromHexRGB:[stylesForCaret valueForKey:@"selection"]];
	[self setCaretColor:[newColor colorWithAlphaComponent:0.5] ];
}

- (void)drawRect:(NSRect)rect {
	
	if( mode != ViCommandMode ){
		return;
	}
	
    // Drawing code here.
    id oakTextView = [self superview];
	
	// TODO: Fix multiple display with selection
	if([oakTextView hasSelection]){
		return;
	}
		
	NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(bounds)]];
	
	[invocation setSelector:@selector(caretRefreshRectangle)];
	[invocation invokeWithTarget:oakTextView];

	NSRect caretRect;
	[invocation getReturnValue:&caretRect];
	
	// TODO: Get the extent of one character in the current font
	caretRect.size.width = 5;
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:caretRect];

    [caretColor set];
    [path fill];
}

@end
