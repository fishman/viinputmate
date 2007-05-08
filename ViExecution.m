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
//    NSLog( @"Finished executing the methodStack" );

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
- (void)visual:(NSNumber *)theIndex
{
    NSLog( @"Setting visual mode" );
    [router setMode:ViVisualMode];
    NSLog( @"Trying to set the mark on the first responder" );
    [responder performSelector: @selector(setMark:) withObject: window];
    NSLog( @"set the mark on the first responder" );
}

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


/**
 * Cut Methods
 */
- (void)cut:(NSNumber *)theIndex
{
    // not needed here  ViCommand handles it.
}

- (void)cutLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(selectLine:) withObject: window];
    [responder performSelector: @selector(writeSelectionToPasteboard:) withObject: window];
    [responder performSelector: @selector(deleteBackward:) withObject: window];
    [router setKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutRight:(NSNumber *)theIndex
{
    NSArray * ranges;
    NSRange range;

    ranges = [responder performSelector: @selector(selectedRanges:) withObject: window];
    NSLog( @"range = %@", [ranges objectAtIndex:0] );
    [responder performSelector: @selector(selectLine:) withObject: window];
    [responder performSelector: @selector(deleteForward:) withObject: window];
}

- (void)cutLeft:(NSNumber *)theIndex
{
    [responder performSelector: @selector(deleteBackward:) withObject: window];
}

- (void)cutToEndOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(deleteToEndOfLine:) withObject: window];
}

- (void)cutToBeginningOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(deleteToBeginningOfLine:) withObject: window];
}


/**
 * Copy Methods
 */
- (void)copy:(NSNumber *)theIndex
{
    // not needed here  ViCommand handles it.
}

- (void)copyLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
    [responder performSelector: @selector(deleteToEndOfLine:) withObject: window];
    [responder performSelector: @selector(deleteBackward:) withObject: window];
    [router setKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyRight:(NSNumber *)theIndex
{
    [responder performSelector: @selector(deleteForward:) withObject: window];
}

- (void)copyLeft:(NSNumber *)theIndex
{
    [responder performSelector: @selector(deleteBackward:) withObject: window];
}

- (void)copyToEndOfLine:(NSNumber *)theIndex
{
}

- (void)copyToBeginningOfLine:(NSNumber *)theIndex
{
}


/**
 * Paste Methods
 */
- (void)pasteBefore:(NSNumber *)theIndex
{
}

- (void)pasteAfter:(NSNumber *)theIndex
{
}




/**
 * NSResponder methods
 */
- (void)moveDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveDown:) withObject: window];
}

- (void)moveDownAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveDownAndModifySelection:) withObject: window];
}

- (void)moveLeft:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveLeft:) withObject: window];
}

- (void)moveLeftAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveLeftAndModifySelection:) withObject: window];
}

- (void)moveRight:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveRight:) withObject: window];
}

- (void)moveRightAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveRightAndModifySelection:) withObject: window];
}

- (void)moveToBeginningOfDocument:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfDocument:) withObject: window];
}

- (void)moveToBeginningOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
}

- (void)moveToEndOfDocument:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToEndOfDocument:) withObject: window];
}

- (void)moveToEndOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToEndOfLine:) withObject: window];
}

- (void)moveUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveUp:) withObject: window];
}

- (void)moveUpAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveUpAndModifySelection:) withObject: window];
}

- (void)pageDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(pageDown:) withObject: window];
}

- (void)pageUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(pageUp:) withObject: window];
}

- (void)scrollLineDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(scrollLineDown:) withObject: window];
}

- (void)scrollLineUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(scrollLineUp:) withObject: window];
}

- (void)selectLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(selectLine:) withObject: window];
}

- (void)selectWord:(NSNumber *)theIndex
{
    [responder performSelector: @selector(selectWord:) withObject: window];
}

@end
