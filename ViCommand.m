//
//  ViCommand.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViCommand.h"
#import "ViEventRouter.h"
#import "ViHelper.h"


@implementation ViCommand

- (id)init
{
    if ( [super init] ) {
        router = [ViEventRouter sharedViEventRouter];
        dataStack = [NSMutableArray arrayWithCapacity: 4];
        methodStack = [NSMutableArray arrayWithCapacity: 4];
        [dataStack retain];
        [methodStack retain];
        execution = [[ViExecution alloc] init];
    }

    return self;
}

- (void)setWindow:(NSWindow *)theWindow
{
    [execution setWindow: theWindow];
}

- (void)pushMethod:(NSString *)theMethod withData:(NSString *)theData
{
    [dataStack addObject: theData];
    [methodStack addObject: theMethod];
    [theData release];
    [theMethod release];
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
        case ViDeleteState:
            [router setActiveKeyMap: @"cutRepeat"];
            break;
        case ViYankState:
            [router setActiveKeyMap: @"yankRepeat"];
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
    [methodStack removeAllObjects];
    [dataStack removeAllObjects];
    [router setMode:ViCommandMode];
    [router setActiveKeyMap:@"commandDefault"];
}

- (void)insert:(id)theEvent
{
    ViLog( @"trying to insert" );
    [self pushMethod:@"insert:" withData:@"i"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertAtBeginningOfLine:(id)theEvent
{
    ViLog( @"trying to insertAtBeginningOfLine" );
    [self pushMethod:@"insertAtBeginningOfLine:" withData:@"I"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)append:(id)theEvent
{
    ViLog( @"trying to moveDown" );
    [self pushMethod:@"append:" withData:@"a"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)appendToEndOfLine:(id)theEvent
{
    ViLog( @"trying to appendToEndOfLine" );
    [self pushMethod:@"appendToEndOfLine:" withData:@"A"];
    [execution executeStack: methodStack withData: dataStack];
}



/**
 * Cut Methods
 */
- (void)cut:(id)theEvent
{
    ViLog( @"changing state to the cut state." );
    [router setActiveKeyMap:@"cutDefault"];
    [router setState:ViDeleteState];
}

- (void)cutLine:(id)theEvent
{
    ViLog( @"trying to cutLine" );
    [self pushMethod:@"cutLine:" withData:@"d"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutRight:(id)theEvent
{
    ViLog( @"trying to cutRight" );
    [self pushMethod:@"cutRight:" withData:@"x"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutLeft:(id)theEvent
{
    ViLog( @"trying to cutLeft" );
    [self pushMethod:@"cutLeft:" withData:@"X"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutWordLeft:(id)theEvent
{
    ViLog( @"trying to cutWordLeft" );
    [self pushMethod:@"cutWordLeft:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutWordRight:(id)theEvent
{
    ViLog( @"trying to cutWordRight" );
    [self pushMethod:@"cutWordRight:" withData:@"w"];
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
    ViLog( @"trying to copyToEndOfLine" );
    [self pushMethod:@"copyToEndOfLine:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyLine:(id)theEvent
{
    ViLog( @"trying to copyToEndOfLine" );
    [self pushMethod:@"copyToEndOfLine:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyRight:(id)theEvent
{
    ViLog( @"trying to copyToEndOfLine" );
    [self pushMethod:@"copyToEndOfLine:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)copyLeft:(id)theEvent
{
    ViLog( @"trying to copyToEndOfLine" );
    [self pushMethod:@"copyToEndOfLine:" withData:@"h"];
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
- (void)moveDown:(id)theEvent
{
    ViLog( @"trying to moveDown" );
    [self pushMethod:@"moveDown:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveDownAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveDownAndModifySelection" );
    [self pushMethod:@"moveDownAndModifySelection:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveLeft:(id)theEvent
{
    ViLog( @"trying to moveLeft" );
    [self pushMethod:@"moveLeft:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveLeftAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveLeftAndModifySelection" );
    [self pushMethod:@"moveLeftAndModifySelection:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveRight:(id)theEvent
{
    ViLog( @"trying to moveRight" );
    [self pushMethod:@"moveRight:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveRightAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveRightAndModifySelection" );
    [self pushMethod:@"moveRightAndModifySelection:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUp:(id)theEvent
{
    ViLog( @"trying to moveUp" );
    [self pushMethod:@"moveUp:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUpAndModifySelection:(id)theEvent
{
    ViLog( @"trying to moveUpAndModifySelection" );
    [self pushMethod:@"moveUpAndModifySelection:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}


/**
 * Word Movement
 */
- (void)moveWordBackward:(id)theEvent
{
    ViLog( @"trying to moveWordBackward" );
    [self pushMethod:@"moveWordBackward:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveWordForward:(id)theEvent
{
    ViLog( @"trying to moveWordForward" );
    [self pushMethod:@"moveWordForward:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}




/**
 * Line methods
 */
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



/**
 * Document movement
 */
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

- (void)undo:(id)theEvent
{
    ViLog( @"trying to undo" );
    [self pushMethod:@"undo:" withData:@"u"];
    [execution executeStack: methodStack withData: dataStack];
}

@end
