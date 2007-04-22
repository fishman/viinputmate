//
//  ViExecution.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViExecution.h"
#import "ViEventRouter.h"


@implementation ViExecution

- (id)init
{
	if ( [super init] ) {
		router = [ViEventRouter sharedViEventRouter];
	}

	return self;
}


- (void)executeStack:(NSMutableArray *)theMethodStack 
			withData:(NSMutableArray *)theDataStack
{
	methodStack = theMethodStack;
	dataStack = theDataStack;
	NSString *method;
	NSNumber *index;

	method = [methodStack objectAtIndex: 0];
	index = [NSNumber numberWithInt: 0];

	[self performSelector: sel_getUid( [method UTF8String] ) withObject: index];
//	NSLog( @"Finished executing the methodStack" );

	[dataStack removeAllObjects];
	[methodStack removeAllObjects];
}

- (void)setWindow:(NSWindow *)theWindow
{
	window = theWindow;
	responder = [theWindow firstResponder];
}


/**
 * vi specific methods
 */
- (void)repeat:(NSNumber *)theIndex
{
	int stackCount = [methodStack count];
	int nextIndex = [theIndex intValue] + 1;
	int repeatCount = [[dataStack objectAtIndex: [theIndex intValue]] intValue];
	int i,j;
	NSString *method;
	NSNumber *index;
	
	for ( j=0; j < repeatCount; j++ ) {

		for ( i = nextIndex; i < stackCount; i++ ) {

			method = [methodStack objectAtIndex: i];
			index = [NSNumber numberWithInt: i];
			NSLog( @"executing method %@ for the %d time.", method, j );
			[self performSelector: sel_getUid( [method UTF8String] ) withObject: index];
		}
	}
}

- (void)resetStack:(NSNumber *)theIndex
{
	// not needed here, ViCommand clears the stack for us
}

- (void)insert:(NSNumber *)theIndex
{
	[router setMode: ViInsertMode];
}

- (void)insertAtBeginningOfLine:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
	[router setMode: ViInsertMode];
}

- (void)append:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveRight:) withObject: window];
	[router setMode: ViInsertMode];
}

- (void)appendToEndOfLine:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveToEndOfLine:) withObject: window];
	[router setMode: ViInsertMode];
}

- (void)delete:(NSNumber *)theIndex
{
	// not needed here  ViCommand handles it.
}

- (void)deleteLine:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
	[responder performSelector: @selector(deleteToEndOfLine:) withObject: window];
	[responder performSelector: @selector(deleteBackward:) withObject: window];
	[router setKeyMap:@"commandDefault"];
	[router setState:ViCommandState];
}

- (void)deleteRight:(NSNumber *)theIndex
{
	if ( [router mode] == ViVisualMode ) {
		[responder performSelector: @selector(deleteToMark:) withObject: window];
		[router setMode: ViCommandMode];
	} else {
		[responder performSelector: @selector(deleteForward:) withObject: window];
	}

	[router setKeyMap:@"commandDefault"];
	[router setState:ViCommandState];
}

- (void)deleteLeft:(NSNumber *)theIndex
{
	if ( [router mode] == ViVisualMode ) {
		[responder performSelector: @selector(deleteToMark:) withObject: window];
		[router setMode: ViCommandMode];
	} else {
		[responder performSelector: @selector(deleteBackward:) withObject: window];
	}

	[router setKeyMap:@"commandDefault"];
	[router setState:ViCommandState];
}

- (void)visual:(NSNumber *)theIndex
{
	NSLog( @"Setting visual mode" );
	[router setMode:ViVisualMode];
	NSLog( @"Trying to set the mark on the first responder" );
	[responder performSelector: @selector(setMark:) withObject: window];
	NSLog( @"set the mark on the first responder" );
}


/**
 * NSResponder methods
 */
- (void)changeCaseOfLetter:(NSNumber *)theIndex
{
}

- (void)deleteBackward:(NSNumber *)theIndex
{
}

- (void)deleteForward:(NSNumber *)theIndex
{
}

- (void)deleteToBeginningOfLine:(NSNumber *)theIndex
{
}

- (void)deleteToBeginningOfParagraph:(NSNumber *)theIndex
{
}

- (void)deleteToEndOfLine:(NSNumber *)theIndex
{
	[responder performSelector: @selector(deleteToEndOfLine:) withObject: window];
}

- (void)deleteToEndOfParagraph:(NSNumber *)theIndex
{
}

- (void)deleteToMark:(NSNumber *)theIndex
{
}

- (void)deleteWordBackward:(NSNumber *)theIndex
{
}

- (void)deleteWordForward:(NSNumber *)theIndex
{
}

- (void)indent:(NSNumber *)theIndex
{
}

- (void)insertBacktab:(NSNumber *)theIndex
{
}

- (void)insertContainerBreak:(NSNumber *)theIndex
{
}

- (void)insertLineBreak:(NSNumber *)theIndex
{
}

- (void)insertNewline:(NSNumber *)theIndex
{
}

- (void)insertNewlineIgnoringFieldEditor:(NSNumber *)theIndex
{
}

- (void)insertParagraphSeparator:(NSNumber *)theIndex
{
}

- (void)insertTab:(NSNumber *)theIndex
{
}

- (void)insertTabIgnoringFieldEditor:(NSNumber *)theIndex
{
}

- (void)insertText:(NSNumber *)theIndex
{
}

- (void)lowercaseWord:(NSNumber *)theIndex
{
}

- (void)moveBackward:(NSNumber *)theIndex
{
}

- (void)moveBackwardAndModifySelection:(NSNumber *)theIndex
{
}

- (void)moveDown:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveDown:) withObject: window];

	if ( [router mode] == ViVisualMode ) {
		[responder performSelector: @selector(selectToMark:) withObject: window];
	}
}

- (void)moveDownAndModifySelection:(NSNumber *)theIndex
{
}

- (void)moveForward:(NSNumber *)theIndex
{
}

- (void)moveForwardAndModifySelection:(NSNumber *)theIndex
{
}

- (void)moveLeft:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveLeft:) withObject: window];

	if ( [router mode] == ViVisualMode ) {
		[responder performSelector: @selector(selectToMark:) withObject: window];
	}
}

- (void)moveLeftAndModifySelection:(NSNumber *)theIndex
{
}

- (void)moveRight:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveRight:) withObject: window];

	if ( [router mode] == ViVisualMode ) {
		[responder performSelector: @selector(selectToMark:) withObject: window];
	}
}

- (void)moveRightAndModifySelection:(NSNumber *)theIndex
{
}

- (void)moveToBeginningOfDocument:(NSNumber *)theIndex
{
}

- (void)moveToBeginningOfLine:(NSNumber *)theIndex
{
}

- (void)moveToBeginningOfParagraph:(NSNumber *)theIndex
{
}

- (void)moveToEndOfDocument:(NSNumber *)theIndex
{
}

- (void)moveToEndOfLine:(NSNumber *)theIndex
{
}

- (void)moveToEndOfParagraph:(NSNumber *)theIndex
{
}

- (void)moveUp:(NSNumber *)theIndex
{
	[responder performSelector: @selector(moveUp:) withObject: window];

	if ( [router mode] == ViVisualMode ) {
		[responder performSelector: @selector(selectToMark:) withObject: window];
	}
}

- (void)moveUpAndModifySelection:(NSNumber *)theIndex
{
}

- (void)pageDown:(NSNumber *)theIndex
{
}

- (void)pageUp:(NSNumber *)theIndex
{
}

- (void)scrollLineDown:(NSNumber *)theIndex
{
}

- (void)scrollLineUp:(NSNumber *)theIndex
{
}

- (void)scrollPageDown:(NSNumber *)theIndex
{
}

- (void)scrollPageUp:(NSNumber *)theIndex
{
}

- (void)selectAll:(NSNumber *)theIndex
{
}

- (void)selectLine:(NSNumber *)theIndex
{
}

- (void)selectParagraph:(NSNumber *)theIndex
{
}

- (void)selectToMark:(NSNumber *)theIndex
{
}

- (void)selectWord:(NSNumber *)theIndex
{
}

- (void)setMark:(NSNumber *)theIndex
{
}

- (void)showContextHelp:(NSNumber *)theIndex
{
}

- (void)swapWithMark:(NSNumber *)theIndex
{
}

- (void)uppercaseWord:(NSNumber *)theIndex
{
}

- (void)yank:(NSNumber *)theIndex
{
}

@end
