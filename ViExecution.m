//
//  ViExecution.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViExecution.h"
#import "ViEventRouter.h"
#import "ViHelper.h"


@implementation ViExecution

- (id)init
{
    if ( [super init] ) {
        router = [ViEventRouter sharedViEventRouter];
        window = nil;
        responder = nil;
        lineNumber = [NSNumber numberWithInt: 0];
        [lineNumber retain];
        columnNumber = [NSNumber numberWithInt: 0];
        [columnNumber retain];
        pasteboard = [NSPasteboard generalPasteboard];
    }

    return self;
}

- (void)dealloc
{
    [responder unbind:@"lineNumber"];
    [responder unbind:@"columnNumber"];
    [lineNumber release];
    [columnNumber release];
    [super dealloc];
}


- (void)setLineNumber:(id)theLineNumber
{
    //ViLog( @"setLineNumber" );
    //ViLog( @"theLineNumber type: %@", [theLineNumber class] );
    [lineNumber release];
    lineNumber = theLineNumber;
    [lineNumber retain];
    //ViLog( @"lineNumber: %@", lineNumber );
}

- (NSNumber *)lineNumber
{
    return lineNumber;
}

- (void)setColumnNumber:(id)theColumnNumber
{
    //ViLog( @"setColumnNumber" );
    //ViLog( @"theColumnNumber type: %@", [theColumnNumber class] );
    [columnNumber release];
    columnNumber = theColumnNumber;
    [columnNumber retain];
    //ViLog( @"columnNumber: %@", columnNumber );
}

- (NSNumber *)columnNumber
{
    return columnNumber;
}



- (void)setWindow:(NSWindow *)theWindow
{
    ViLog( @"Setting the Window" );

    // cleanup
    if ( responder != nil ) {
        [responder unbind:@"lineNumber"];
        [responder unbind:@"columnNumber"];
    }

    window = theWindow;
    responder = [theWindow firstResponder];

    ViLog( @"Binding parameters" );
    [responder bind:@"lineNumber"   toObject:self withKeyPath:@"lineNumber"   options:nil];
    [responder bind:@"columnNumber" toObject:self withKeyPath:@"columnNumber" options:nil];
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
//    ViLog( @"Finished executing the methodStack" );

    [dataStack removeAllObjects];
    [methodStack removeAllObjects];
}


/**
 * vi specific methods
 */
- (void)visual:(NSNumber *)theIndex
{
    ViLog( @"Setting visual mode" );
    [router setState:ViVisualState];
    [router setActiveKeyMap:@"visualDefault"];
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
            ViLog( @"executing method %@ for the %d time.", method, j );
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
    // not needed, ViCommand Takes care of it.
    /*
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        ViLog( @"No selection found" );
        return;
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
    */
}

- (void)cutLine:(NSNumber *)theIndex
{
    NSArray * types = [NSArray arrayWithObject:@"NSStringPboardType"];

    ViLog( @"Trying to cutLine" );
    [responder performSelector: @selector(selectLine:) withObject: window];
    [responder writeSelectionToPasteboard:pasteboard types:types];
    [responder performSelector: @selector(deleteBackward:) withObject: window];
     
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutRight:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        [responder performSelector: @selector(moveRightAndModifySelection:) 
                        withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutLeft:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        [responder performSelector: @selector(moveLeftAndModifySelection:) 
                        withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutWordRight:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordRightAndModifySelection:) withObject: window];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutWordLeft:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordLeftAndModifySelection:) withObject: window];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutToEndOfLine:(NSNumber *)theIndex
{
    int column = [columnNumber intValue];

    [responder performSelector: @selector(moveToEndOfLine:) withObject: window];

    while ( column < [columnNumber intValue] ) {
        [responder performSelector: @selector(moveLeftAndModifySelection:) withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutToBeginningOfLine:(NSNumber *)theIndex
{
    int column = [columnNumber intValue];

    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];

    while ( column > [columnNumber intValue] ) {
        [responder performSelector: @selector(moveRightAndModifySelection:) withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}



/**
 * Copy Methods
 */
- (void)copy:(NSNumber *)theIndex
{
    // not needed, ViCommand Takes care of it.
    /*
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        ViLog( @"No selection found" );
        return;
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
    */
}

- (void)copyLine:(NSNumber *)theIndex
{
    NSArray * types = [NSArray arrayWithObject:@"NSStringPboardType"];

    ViLog( @"Trying to cutLine" );
    [responder performSelector: @selector(selectLine:) withObject: window];
    [responder writeSelectionToPasteboard:pasteboard types:types];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyRight:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        [responder performSelector: @selector(moveRightAndModifySelection:) 
                        withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyLeft:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        [responder performSelector: @selector(moveLeftAndModifySelection:) 
                        withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyWordRight:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordRightAndModifySelection:) withObject: window];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyWordLeft:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordLeftAndModifySelection:) withObject: window];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyToEndOfLine:(NSNumber *)theIndex
{
    int column = [columnNumber intValue];

    [responder performSelector: @selector(moveToEndOfLine:) withObject: window];

    while ( column < [columnNumber intValue] ) {
        [responder performSelector: @selector(moveLeftAndModifySelection:) withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyToBeginningOfLine:(NSNumber *)theIndex
{
    int column = [columnNumber intValue];

    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];

    while ( column > [columnNumber intValue] ) {
        [responder performSelector: @selector(moveRightAndModifySelection:) withObject: window];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}



/**
 * Paste Methods
 */
- (void)pasteBefore:(NSNumber *)theIndex
{
    NSString * str = [pasteboard stringForType:@"NSStringPboardType"];

    if ( [str length] > 0 ) {

        if ( [str characterAtIndex:( [str length] - 1 )] == '\n' ) {
            //ViLog( @"pasteBefore as a new line." );
            [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
            [responder readSelectionFromPasteboard:pasteboard];
            [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
        } else {
            //ViLog( @"pasteBefore as a string." );
            [responder readSelectionFromPasteboard:pasteboard];
        }
    }
     
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)pasteAfter:(NSNumber *)theIndex
{
    NSString * str = [pasteboard stringForType:@"NSStringPboardType"];

    if ( [str length] > 0 ) {

        if ( [str characterAtIndex:( [str length] - 1 )] == '\n' ) {
            //ViLog( @"pasteAfter as a new line." );
            str = [str substringToIndex:( [str length] - 1 )];
            str = [@"\n" stringByAppendingString: str];
            [responder performSelector: @selector(moveToEndOfLine:) withObject: window];
            [responder insertText:str];
            [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
        } else {
            //ViLog( @"pasteAfter as a string." );
            [self moveRight:theIndex];
            [responder readSelectionFromPasteboard:pasteboard];
        }
    }
     
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
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
    if ( [columnNumber intValue] > 0 ) {
        [responder performSelector: @selector(moveLeft:) withObject: window];
    }
}

- (void)moveLeftAndModifySelection:(NSNumber *)theIndex
{
    if ( [columnNumber intValue] > 0 ) {
        [responder performSelector: @selector(moveLeftAndModifySelection:) withObject: window];
    }
}

- (void)moveRight:(NSNumber *)theIndex
{
    int line = [lineNumber intValue];

    [responder performSelector: @selector(moveRight:) withObject: window];

    if ( [lineNumber intValue] > line ) {
        [responder performSelector: @selector(moveLeft:) withObject: window];
    }
}

- (void)moveRightAndModifySelection:(NSNumber *)theIndex
{
    int line = [lineNumber intValue];

    [responder performSelector: @selector(moveRightAndModifySelection:) withObject: window];

    if ( [lineNumber intValue] > line ) {
        [responder performSelector: @selector(moveLeftAndModifySelection:) withObject: window];
    }
}

- (void)moveUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveUp:) withObject: window];
}

- (void)moveUpAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveUpAndModifySelection:) withObject: window];
}


/**
 * Word Movement
 */
- (void)moveWordBackward:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordBackward:) withObject: window];
}

- (void)moveWordForward:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordForward:) withObject: window];
}




- (void)moveToBeginningOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
}

- (void)moveToEndOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToEndOfLine:) withObject: window];
}


- (void)moveToBeginningOfDocument:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfDocument:) withObject: window];
}

- (void)moveToEndOfDocument:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToEndOfDocument:) withObject: window];
}



- (void)scrollPageDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(pageDown:) withObject: window];
}

- (void)scrollPageUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(pageUp:) withObject: window];
}


- (void)scrollHalfPageDown:(NSNumber *)theIndex
{
    //ViLog( @"trying to determine height" );
    //ViLog( @"height: %@", [window frame] );
    //float height = [window frame].size.height;
    //ViLog( @"height: %@", height );
    //[responder scrollViewByX:0.0 byY: 1.0];
}

- (void)scrollHalfPageUp:(NSNumber *)theIndex
{
    //ViLog( @"height: %@", [window frame] );
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


- (void)undo:(NSNumber *)theIndex
{
    //[responder undo];
}

@end
