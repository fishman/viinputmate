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
		[self setCaretColor: [[NSColor greenColor] colorWithAlphaComponent:0.5]];
		[[self window] setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
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

#define FixedToFloat(a) ((float)(a) / fixed1)

- (void)setMode:(ViMode)theMode
{
	mode = theMode;
	id oakTextView = [self superview];
	NSDictionary * stylesForCaret = [oakTextView stylesForCaret];
	NSColor * newColor = [NSColor colorFromHexRGB:[stylesForCaret valueForKey:@"caret"]];
	[self setCaretColor:[newColor colorWithAlphaComponent:0.5] ];
	
	[self setNeedsDisplay:TRUE];

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
	// TODO: TextLayout::charWidth(void) the calculation shouldn't be done each time it is drawn tho.
	// *(*(OakTextView+0x68)+0x10)
#warning ATSUI_render position in OakTextView may vary through textmate versions
	// TODO: ask allan if he can implement this - (float) charWidth:(OakTextView)oakTextView { Fixed charWidth; charWidth = TextLayout::charWidth(oakTextView->render); return FixedToFloat(charWidth);}
	int * ATSUI_render = *((int*)oakTextView+26);
	Fixed M_charWidth = *(Fixed*)(ATSUI_render+4);
	
	caretRect.size.width = FixedToFloat(M_charWidth);
	NSBezierPath * path = [NSBezierPath bezierPathWithRect:caretRect];

	[caretColor set];
	[path fill];
}

@end