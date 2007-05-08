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
- (void)visual:(id)theEvent
{
    NSLog( @"trying to enter visual mode" );
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
            [router setKeyMap: @"cutRepeat"];
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

- (void)cut:(id)theEvent
{
    NSLog( @"changing state to the cut state." );
    [router setKeyMap:@"cutDefault"];
    [router setState:ViDeleteState];
}

- (void)cutLine:(id)theEvent
{
    NSLog( @"trying to cutLine" );
    [self pushMethod:@"cutLine:" withData:@"d"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutRight:(id)theEvent
{
    NSLog( @"trying to cutRight" );
    [self pushMethod:@"cutRight:" withData:@"x"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)cutLeft:(id)theEvent
{
    NSLog( @"trying to cutLeft" );
    [self pushMethod:@"cutLeft:" withData:@"X"];
    [execution executeStack: methodStack withData: dataStack];
}


/**
 * Select NSResponder Methods
 */
- (void)cutToEndOfLine:(id)theEvent
{
    NSLog( @"trying to cutToEndOfLine" );
    [self pushMethod:@"cutToEndOfLine:" withData:@"D"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveDown:(id)theEvent
{
    NSLog( @"trying to moveDown" );
    [self pushMethod:@"moveDown:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveDownAndModifySelection:(id)theEvent
{
    NSLog( @"trying to moveDownAndModifySelection" );
    [self pushMethod:@"moveDownAndModifySelection:" withData:@"j"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveLeft:(id)theEvent
{
    NSLog( @"trying to moveLeft" );
    [self pushMethod:@"moveLeft:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveLeftAndModifySelection:(id)theEvent
{
    NSLog( @"trying to moveLeftAndModifySelection" );
    [self pushMethod:@"moveLeftAndModifySelection:" withData:@"h"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveRight:(id)theEvent
{
    NSLog( @"trying to moveRight" );
    [self pushMethod:@"moveRight:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveRightAndModifySelection:(id)theEvent
{
    NSLog( @"trying to moveRightAndModifySelection" );
    [self pushMethod:@"moveRightAndModifySelection:" withData:@"l"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToBeginningOfDocument:(id)theEvent
{
    NSLog( @"trying to moveToBeginningOfDocument" );
    [self pushMethod:@"moveToBeginningOfDocument:" withData:@"gg"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToBeginningOfLine:(id)theEvent
{
    NSLog( @"trying to moveToBeginningOfLine" );
    [self pushMethod:@"moveToBeginningOfLine:" withData:@"0"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToEndOfDocument:(id)theEvent
{
    NSLog( @"trying to moveToEndOfDocument" );
    [self pushMethod:@"moveToEndOfDocument:" withData:@"G"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveToEndOfLine:(id)theEvent
{
    NSLog( @"trying to moveToEndOfLine" );
    [self pushMethod:@"moveToEndOfLine:" withData:@"$"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUp:(id)theEvent
{
    NSLog( @"trying to moveUp" );
    [self pushMethod:@"moveUp:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)moveUpAndModifySelection:(id)theEvent
{
    NSLog( @"trying to moveUpAndModifySelection" );
    [self pushMethod:@"moveUpAndModifySelection:" withData:@"k"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)pageDown:(id)theEvent
{
    NSLog( @"trying to pageDown" );
    [self pushMethod:@"pageDown:" withData:@"f"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)pageUp:(id)theEvent
{
    NSLog( @"trying to pageUp" );
    [self pushMethod:@"pageUp:" withData:@"b"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollLineDown:(id)theEvent
{
    NSLog( @"trying to scrollLineDown" );
    [self pushMethod:@"scrollLineDown:" withData:@"e"];
    [execution executeStack: methodStack withData: dataStack];
}

- (void)scrollLineUp:(id)theEvent
{
    NSLog( @"trying to scrollLineUp" );
    [self pushMethod:@"scrollLineUp:" withData:@"y"];
    [execution executeStack: methodStack withData: dataStack];
}


@end
