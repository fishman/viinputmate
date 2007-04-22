//
//  ViCommand.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViCommand.h"
#import "ViEventRouter.h"


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
- (void)repeat:(id)theEvent
{
    int value;

    if ( ( [methodStack count] > 0 ) && [[methodStack lastObject] isEqualToString: @"repeat:"] ) {
        // add the new number to the number that is already on the dataStack.
        // no need to add the method name to the stack since it is
        // already there.
        NSLog( @"Adding to the repeat command" );
        value = [[dataStack lastObject] intValue] * 10;
        value += [[theEvent charactersIgnoringModifiers] intValue];
        [dataStack removeLastObject];
    } else {
        // add the number that was pressed to the data stack and 
        // add the repeat method name to the method stack for the 
        // first time.
        NSLog( @"Creating a new repeat command" );
        value = [[theEvent charactersIgnoringModifiers] intValue];
        [methodStack addObject: @"repeat:"];
        [[methodStack lastObject] release];
    }

    [dataStack addObject: [NSNumber numberWithInt: value]];

    switch ( [router state] ) {
        case ViDeleteState:
            [router setKeyMap: @"deleteRepeat"];
            break;
        case ViYankState:
            [router setKeyMap: @"yankRepeat"];
            break;
        case ViCommandState:
        default:
            [router setKeyMap: @"commandRepeat"];
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
    [router setKeyMap:@"commandDefault"];
}

- (void)insert:(id)theEvent
{
    NSLog( @"trying to insert" );
    [self pushMethod:@"insert:" withData:@"i"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)insertAtBeginningOfLine:(id)theEvent
{
    NSLog( @"trying to insertAtBeginningOfLine" );
    [self pushMethod:@"insertAtBeginningOfLine:" withData:@"I"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)append:(id)theEvent
{
    NSLog( @"trying to moveDown" );
    [self pushMethod:@"append:" withData:@"a"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)appendToEndOfLine:(id)theEvent
{
    NSLog( @"trying to appendToEndOfLine" );
    [self pushMethod:@"appendToEndOfLine:" withData:@"A"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)delete:(id)theEvent
{
    [router setKeyMap:@"deleteDefault"];
    [router setState:ViDeleteState];
}

- (void)deleteLine:(id)theEvent
{
    NSLog( @"trying to deleteLine" );
    [self pushMethod:@"deleteLine:" withData:@"d"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)deleteRight:(id)theEvent
{
    NSLog( @"trying to deleteRight" );
    [self pushMethod:@"deleteRight:" withData:@"x"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)deleteLeft:(id)theEvent
{
    NSLog( @"trying to deleteLeft" );
    [self pushMethod:@"deleteLeft:" withData:@"X"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)visual:(id)theEvent
{
    NSLog( @"trying to enter visual mode" );
    [self pushMethod:@"visual:" withData:@"v"];
    [execution executeStack: methodStack withData: dataStack];
}


/**
 * NSResponder methods
 */
- (void)changeCaseOfLetter:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteBackward:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteForward:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteToBeginningOfLine:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteToBeginningOfParagraph:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteToEndOfLine:(id)theEvent
{
    NSLog( @"trying to deleteToEndOfLine" );
    [self pushMethod:@"deleteToEndOfLine:" withData:@"D"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)deleteToEndOfParagraph:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteToMark:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteWordBackward:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)deleteWordForward:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)indent:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertBacktab:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertContainerBreak:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertLineBreak:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertNewline:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertNewlineIgnoringFieldEditor:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertParagraphSeparator:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertTab:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertTabIgnoringFieldEditor:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)insertText:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)lowercaseWord:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveBackward:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveBackwardAndModifySelection:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveDown:(id)theEvent
{
    NSLog( @"trying to moveDown" );
    [self pushMethod:@"moveDown:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveDownAndModifySelection:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveForward:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveForwardAndModifySelection:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveLeft:(id)theEvent
{
    NSLog( @"trying to moveLeft" );
    [self pushMethod:@"moveLeft:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveLeftAndModifySelection:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveRight:(id)theEvent
{
    NSLog( @"trying to moveRight" );
    [self pushMethod:@"moveRight:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveRightAndModifySelection:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveToBeginningOfDocument:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveToBeginningOfLine:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveToBeginningOfParagraph:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveToEndOfDocument:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveToEndOfLine:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveToEndOfParagraph:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)moveUp:(id)theEvent
{
    NSLog( @"trying to moveUp" );
    [self pushMethod:@"moveUp:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUpAndModifySelection:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)pageDown:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)pageUp:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)scrollLineDown:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)scrollLineUp:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)scrollPageDown:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)scrollPageUp:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)selectAll:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)selectLine:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)selectParagraph:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)selectToMark:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)selectWord:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)setMark:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)showContextHelp:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)swapWithMark:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)uppercaseWord:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

- (void)yank:(id)theEvent
{
    NSLog( @"Not Yet Implemented" );
}

@end
