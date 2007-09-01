//
//  ViController.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViController.h"
#import "ViEventDispatcher.h"
#import "ViHelper.h"


@implementation ViController

- (id)init
{
    if ( [super init] ) {
        router = [ViEventDispatcher sharedViEventDispatcher];
        dataStack = [NSMutableArray arrayWithCapacity: 4];
        methodStack = [NSMutableArray arrayWithCapacity: 4];
        [dataStack retain];
        [methodStack retain];
        execution = [[ViEditor alloc] init];
        repeatOn = false;
    }

    return self;
}

- (void)setWindow:(NSWindow *)theWindow
{
    [execution setWindow: theWindow];
}

- (void)releaseWindow:(NSWindow *)theWindow
{
	[execution releaseWindow:theWindow];
}

- (void)pushMethod:(NSString *)theMethod withData:(NSString *)theData
{
    [dataStack addObject: theData];
    [methodStack addObject: theMethod];
    [theData release];
    [theMethod release];
}

- (void)setActiveKeyMap:(NSString *)theMapName
{
    if ( repeatOn ) {
    } else {
    }
}



/**
 * vi specific methods
 */
- (void)visual:(id)theEvent
{
    ViLog( @"trying to enter visual mode" );
    [self pushMethod:@"visual:" withData:@"v"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)repeat:(id)theEvent
{
    int value;

    if ( ( [methodStack count] > 0 ) && [[methodStack lastObject] isEqualToString: @"repeat:"] ) {
        // add the new number to the number that is already on the dataStack.
        // no need to add the method name to the stack since it is
        // already there.
        ViLog( @"Adding to the repeat command" );
        value = [[dataStack lastObject] intValue] * 10;
        value += [[theEvent charactersIgnoringModifiers] intValue];
        [dataStack removeLastObject];
    } else {
        // add the number that was pressed to the data stack and 
        // add the repeat method name to the method stack for the 
        // first time.
        ViLog( @"Creating a new repeat command" );
        value = [[theEvent charactersIgnoringModifiers] intValue];
        [methodStack addObject: @"repeat:"];
        [[methodStack lastObject] release];
    }

    [dataStack addObject: [NSNumber numberWithInt: value]];

    switch ( [router state] ) {
        case ViCutState:
            [router setActiveKeyMap: @"cutRepeat"];
            break;
        case ViCopyState:
            [router setActiveKeyMap: @"copyRepeat"];
            break;
        case ViChangeState:
            [router setActiveKeyMap: @"changeRepeat"];
            break;
        case ViVisualState:
            [router setActiveKeyMap: @"visualRepeat"];
            break;
        case ViCommandState:
        default:
            [router setActiveKeyMap: @"commandRepeat"];
            break;
    }
    // for some reason this causes the program to crash.
    //[[dataStack lastObject] release];
}

- (void)resetStack:(id)theEvent
{
    ViLog( @"trying to resetStack" );
    [methodStack removeAllObjects];
    [dataStack removeAllObjects];
    [router setMode:ViCommandMode];
    [router setState:ViCommandState];
    [router setActiveKeyMap:@"commandDefault"];
    [self pushMethod:@"resetStack:" withData:@"esc"];
    [execution executeStack: methodStack withData: dataStack];
}



/**
 * Insert Methods
 */
- (void)insertBackward:(id)theEvent
{
    ViLog( @"trying to insertBackward" );
    [self pushMethod:@"insertBackward:" withData:@"i"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertForward:(id)theEvent
{
    ViLog( @"trying to insertForward" );
    [self pushMethod:@"insertForward:" withData:@"a"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertAbove:(id)theEvent
{
    ViLog( @"trying to insertAbove" );
    [self pushMethod:@"insertAbove:" withData:@"O"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertBelow:(id)theEvent
{
    ViLog( @"trying to insertBelow" );
    [self pushMethod:@"insertBelow:" withData:@"o"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertAtBeginningOfLine:(id)theEvent
{
    ViLog( @"trying to insertAtBeginningOfLine" );
    [self pushMethod:@"insertAtBeginningOfLine:" withData:@"I"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertAtEndOfLine:(id)theEvent
{
    ViLog( @"trying to insertAtEndOfLine" );
    [self pushMethod:@"insertAtEndOfLine:" withData:@"A"];
    [execution executeStack: methodStack withData: dataStack];
}



/**
 * Cut Methods
 */
- (void)cut:(id)theEvent
{
    ViLog( @"trying to cut" );
    [self pushMethod:@"cut:" withData:@"d"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutState:(id)theEvent
{
    ViLog( @"changing state to the cut state." );
    [router setActiveKeyMap:@"cutDefault"];
    [router setState:ViCutState];
}

- (void)cutLine:(id)theEvent
{
    ViLog( @"trying to cutLine" );
    [self pushMethod:@"cutLine:" withData:@"d"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutForward:(id)theEvent
{
    ViLog( @"trying to cutForward" );
    [self pushMethod:@"cutForward:" withData:@"x"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutBackward:(id)theEvent
{
    ViLog( @"trying to cutBackward" );
    [self pushMethod:@"cutBackward:" withData:@"X"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutWordBackward:(id)theEvent
{
    ViLog( @"trying to cutWordBackward" );
    [self pushMethod:@"cutWordBackward:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutWordForward:(id)theEvent
{
    ViLog( @"trying to cutWordForward" );
    [self pushMethod:@"cutWordForward:" withData:@"w"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutToEndOfWord:(id)theEvent
{
    ViLog( @"trying to cutToEndOfWord" );
    [self pushMethod:@"cutToEndOfWord:" withData:@"w"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutToEndOfLine:(id)theEvent
{
    ViLog( @"trying to cutToEndOfLine" );
    [self pushMethod:@"cutToEndOfLine:" withData:@"D"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutToBeginningOfLine:(id)theEvent
{
    ViLog( @"trying to cutToBeginningOfLine" );
    [self pushMethod:@"cutToBeginningOfLine:" withData:@"0"];
    [execution executeStack: methodStack withData: dataStack];
}


/**
 * Copy Methods
 */
- (void)copy:(id)theEvent
{
    ViLog( @"trying to copy" );
    [self pushMethod:@"copy:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyState:(id)theEvent
{
    ViLog( @"trying to set copyState" );
    [router setActiveKeyMap:@"copyDefault"];
    [router setState:ViCopyState];
}

- (void)copyLine:(id)theEvent
{
    ViLog( @"trying to copyLine" );
    [self pushMethod:@"copyLine:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyForward:(id)theEvent
{
    ViLog( @"trying to copyForward" );
    [self pushMethod:@"copyForward:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyBackward:(id)theEvent
{
    ViLog( @"trying to copyBackward" );
    [self pushMethod:@"copyBackward:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyWordForward:(id)theEvent
{
    ViLog( @"trying to copyWordForward" );
    [self pushMethod:@"copyWordForward:" withData:@"w"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyWordBackward:(id)theEvent
{
    ViLog( @"trying to copyWordBackward" );
    [self pushMethod:@"copyWordBackward:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyToEndOfWord:(id)theEvent
{
    ViLog( @"trying to copyToEndOfWord" );
    [self pushMethod:@"copyToEndOfWord:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyToEndOfLine:(id)theEvent
{
    ViLog( @"trying to copyToEndOfLine" );
    [self pushMethod:@"copyToEndOfLine:" withData:@"$"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyToBeginningOfLine:(id)theEvent
{
    ViLog( @"trying to copyToBeginningOfLine" );
    [self pushMethod:@"copyToBeginningOfLine:" withData:@"0"];
    [execution executeStack: methodStack withData: dataStack];
}




/**
 * Change Methods
 */
- (void)change:(id)theEvent
{
    ViLog( @"trying to change" );
    [self pushMethod:@"change:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeState:(id)theEvent
{
    ViLog( @"trying to set changeState" );
    [router setActiveKeyMap:@"changeDefault"];
    [router setState:ViCopyState];
}

- (void)changeLine:(id)theEvent
{
    ViLog( @"trying to changeLine" );
    [self pushMethod:@"changeLine:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeForward:(id)theEvent
{
    ViLog( @"trying to changeForward" );
    [self pushMethod:@"changeForward:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeBackward:(id)theEvent
{
    ViLog( @"trying to changeBackward" );
    [self pushMethod:@"changeBackward:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeWordForward:(id)theEvent
{
    ViLog( @"trying to changeWordForward" );
    [self pushMethod:@"changeWordForward:" withData:@"w"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeWordBackward:(id)theEvent
{
    ViLog( @"trying to changeWordBackward" );
    [self pushMethod:@"changeWordBackward:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeToEndOfWord:(id)theEvent
{
    ViLog( @"trying to changeToEndOfWord" );
    [self pushMethod:@"changeToEndOfWord:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeToEndOfLine:(id)theEvent
{
    ViLog( @"trying to changeToEndOfLine" );
    [self pushMethod:@"changeToEndOfLine:" withData:@"$"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)changeToBeginningOfLine:(id)theEvent
{
    ViLog( @"trying to changeToBeginningOfLine" );
    [self pushMethod:@"changeToBeginningOfLine:" withData:@"0"];
    [execution executeStack: methodStack withData: dataStack];
}




/**
 * Paste Methods
 */
- (void)pasteBefore:(id)theEvent
{
    ViLog( @"trying to pasteBefore" );
    [self pushMethod:@"pasteBefore:" withData:@"P"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)pasteAfter:(id)theEvent
{
    ViLog( @"trying to pasteAfter" );
    [self pushMethod:@"pasteAfter:" withData:@"p"];
    [execution executeStack: methodStack withData: dataStack];
}




/**
 * Select NSResponder Methods
 */
- (void)moveForward:(id)theEvent
{
    ViLog( @"trying to moveForward" );
    [self pushMethod:@"moveForward:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveBackward:(id)theEvent
{
    ViLog( @"trying to moveBackward" );
    [self pushMethod:@"moveBackward:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUp:(id)theEvent
{
    ViLog( @"trying to moveUp" );
    [self pushMethod:@"moveUp:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveDown:(id)theEvent
{
    ViLog( @"trying to moveDown" );
    [self pushMethod:@"moveDown:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveWordBackward:(id)theEvent
{
    ViLog( @"trying to moveWordBackward" );
    [self pushMethod:@"moveWordBackward:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveWordForward:(id)theEvent
{
    ViLog( @"trying to moveWordForward" );
    [self pushMethod:@"moveWordForward:" withData:@"w"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToEndOfWord:(id)theEvent
{
    ViLog( @"trying to moveToEndOfWord" );
    [self pushMethod:@"moveToEndOfWord:" withData:@"e"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToBeginningOfLine:(id)theEvent
{
    ViLog( @"trying to moveToBeginningOfLine" );
    [self pushMethod:@"moveToBeginningOfLine:" withData:@"0"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToEndOfLine:(id)theEvent
{
    ViLog( @"trying to moveToEndOfLine" );
    [self pushMethod:@"moveToEndOfLine:" withData:@"$"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToBeginningOfDocument:(id)theEvent
{
    ViLog( @"trying to moveToBeginningOfDocument" );
    [self pushMethod:@"moveToBeginningOfDocument:" withData:@"gg"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToEndOfDocument:(id)theEvent
{
    ViLog( @"trying to moveToEndOfDocument" );
    [self pushMethod:@"moveToEndOfDocument:" withData:@"G"];
    [execution executeStack: methodStack withData: dataStack];
}




/**
 * Visual Movement Methods
 */
- (void)moveForwardAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveForwardAndModifySelection" );
    [self pushMethod:@"moveForwardAndModifySelection:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveBackwardAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveBackwardAndModifySelection" );
    [self pushMethod:@"moveBackwardAndModifySelection:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUpAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveUpAndModifySelection" );
    [self pushMethod:@"moveUpAndModifySelection:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveDownAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveDownAndModifySelection" );
    [self pushMethod:@"moveDownAndModifySelection:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveWordBackwardAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveWordBackwardAndModifySelection" );
    [self pushMethod:@"moveWordBackwardAndModifySelection:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveWordForwardAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveWordForwardAndModifySelection" );
    [self pushMethod:@"moveWordForwardAndModifySelection:" withData:@"w"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToEndOfWordAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveToEndOfWordAndModifySelection" );
    [self pushMethod:@"moveToEndOfWordAndModifySelection:" withData:@"e"];
    [execution executeStack: methodStack withData: dataStack];
}



/**
 * Scroll Methods
 */
- (void)scrollLineDown:(id)theEvent
{
    ViLog( @"trying to scrollLineDown" );
    [self pushMethod:@"scrollLineDown:" withData:@"e"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollLineUp:(id)theEvent
{
    ViLog( @"trying to scrollLineUp" );
    [self pushMethod:@"scrollLineUp:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollHalfPageDown:(id)theEvent
{
    ViLog( @"trying to scrollHalfPageDown" );
    [self pushMethod:@"scrollHalfPageDown:" withData:@"d"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollHalfPageUp:(id)theEvent
{
    ViLog( @"trying to scrollHalfPageUp" );
    [self pushMethod:@"scrollHalfPageUp:" withData:@"u"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollPageDown:(id)theEvent
{
    ViLog( @"trying to scrollPageDown" );
    [self pushMethod:@"scrollPageDown:" withData:@"f"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollPageUp:(id)theEvent
{
    ViLog( @"trying to scrollPageUp" );
    [self pushMethod:@"scrollPageUp:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)undo:(id)theEvent
{
    ViLog( @"trying to undo" );
    [self pushMethod:@"undo:" withData:@"u"];
    [execution executeStack: methodStack withData: dataStack];
}

@end
