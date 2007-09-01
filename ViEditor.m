//
//  ViEditor.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViEditor.h"
#import "ViEventDispatcher.h"
#import "ViHelper.h"


@implementation ViEditor

- (id)init
{
    if ( [super init] ) {
        router = [ViEventDispatcher sharedViEventDispatcher];
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
    ViLog( @"%s %@", _cmd, @"cleanup" );
    if ( responder != nil ) {
        [responder unbind:@"lineNumber"];
        [responder unbind:@"columnNumber"];
    }

    ViLog( @"%s %@ [%@]", _cmd, @"Setting the Window", theWindow );
    window = theWindow;
    responder = [theWindow firstResponder];

    ViLog( @"%s %@", _cmd, @"Binding parameters" );
    [responder bind:@"lineNumber"   toObject:self withKeyPath:@"lineNumber"   options:nil];
    [responder bind:@"columnNumber" toObject:self withKeyPath:@"columnNumber" options:nil];
}

- (void)releaseWindow:(NSWindow *)theWindow
{
	responder = nil;
	window = nil;
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
    if ( [responder hasSelection] ) {
    	[responder performSelector: @selector(moveBackward:) withObject: window];
	}
}


/**
 * Insert Methods
 */
- (void)insertBackward:(NSNumber *)theIndex
{
    [router setMode: ViInsertMode];
}

- (void)insertForward:(NSNumber *)theIndex
{
	[self moveForward];
    [router setMode: ViInsertMode];
}

- (void)insertAbove:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
    [responder insertText:@"\n"];
    [responder performSelector: @selector(moveUp:) withObject: window];
    [router setMode: ViInsertMode];
}

- (void)insertBelow:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToEndOfLine:) withObject: window];
    [responder insertText:@"\n"];
    [router setMode: ViInsertMode];
}

- (void)insertAtBeginningOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
    [router setMode: ViInsertMode];
}

- (void)insertAtEndOfLine:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveToEndOfLine:) withObject: window];
    [router setMode: ViInsertMode];
}


/**
 * Cut Methods
 */
- (void)cut:(NSNumber *)theIndex
{
    // if nothing is selected then we do nothing
    if ( ! [responder hasSelection] ) {
        ViLog( @"No selection found" );
        return;
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
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

- (void)cutForward:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        //[responder performSelector: @selector(moveForwardAndModifySelection:) withObject: window];
		[self moveForwardAndModifySelection:nil];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutBackward:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        //[responder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
		[self moveBackwardAndModifySelection:nil];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutWordForward:(NSNumber *)theIndex
{
    //[responder performSelector: @selector(moveWordForwardAndModifySelection:) withObject: window];
	[self moveWordForwardAndModifySelection:nil];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutWordBackward:(NSNumber *)theIndex
{
    //[responder performSelector: @selector(moveWordBackwardAndModifySelection:) withObject: window];
	[self moveWordBackwardAndModifySelection:nil];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(deleteBackward:) withObject: window];

    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)cutToEndOfWord:(NSNumber *)theIndex
{
    //[responder performSelector: @selector(moveWordBackwardAndModifySelection:) withObject: window];
	[self moveToEndOfWordAndModifySelection:nil];
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
        [responder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
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
        [responder performSelector: @selector(moveForwardAndModifySelection:) withObject: window];
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
    // if nothing is selected then we do nothing.
    if ( ! [responder hasSelection] ) {
        ViLog( @"No selection found" );
        return;
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
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

- (void)copyForward:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        //[responder performSelector: @selector(moveForwardAndModifySelection:) withObject: window];
		[self moveForwardAndModifySelection:nil];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyBackward:(NSNumber *)theIndex
{
    // if nothing is selected then we should select the 
    // first character to the right.
    if ( ! [responder hasSelection] ) {
        //[responder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
		[self moveBackwardAndModifySelection:nil];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyWordForward:(NSNumber *)theIndex
{
    //[responder performSelector: @selector(moveWordForwardAndModifySelection:) withObject: window];
	[self moveWordForwardAndModifySelection:nil];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyWordBackward:(NSNumber *)theIndex
{
    //[responder performSelector: @selector(moveWordBackwardAndModifySelection:) withObject: window];
	[self moveWordBackwardAndModifySelection:nil];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
	//[self moveBackward:nil];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyToEndOfWord:(NSNumber *)theIndex
{
    //[responder performSelector: @selector(moveWordBackwardAndModifySelection:) withObject: window];
	[self moveToEndOfWordAndModifySelection:nil];
    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
	//[self moveBackward:nil];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyToEndOfLine:(NSNumber *)theIndex
{
    int column = [columnNumber intValue];

    //[responder performSelector: @selector(moveToEndOfLine:) withObject: window];
	[self moveToEndOfLine:nil];

    while ( column < [columnNumber intValue] ) {
        [responder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
		//[self moveBackwardAndModifySelection:nil];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
	//[self moveBackward:nil];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}

- (void)copyToBeginningOfLine:(NSNumber *)theIndex
{
    int column = [columnNumber intValue];

    //[responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
	[self moveToBeginningOfLine:nil];

    while ( column > [columnNumber intValue] ) {
        [responder performSelector: @selector(moveForwardAndModifySelection:) withObject: window];
		//[self moveForwardAndModifySelection:nil];
    }

    [responder writeSelectionToPasteboard:pasteboard 
                                    types:[NSArray arrayWithObject:@"NSStringPboardType"] ];
    [responder performSelector: @selector(moveBackward:) withObject: window];
	//[self moveBackward:nil];
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}



/**
 * Change Methods
 */
- (void)change:(NSNumber *)theIndex
{
	[self cut:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeLine:(NSNumber *)theIndex
{
	[self cutLine:theIndex];
	[self insertAbove:theIndex];
}

- (void)changeForward:(NSNumber *)theIndex
{
	[self cutForward:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeBackward:(NSNumber *)theIndex
{
	[self cutBackward:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeWordForward:(NSNumber *)theIndex
{
	[self cutWordForward:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeWordBackward:(NSNumber *)theIndex
{
	[self cutWordBackward:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeToEndOfWord:(NSNumber *)theIndex
{
	[self cutToEndOfWord:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeToEndOfLine:(NSNumber *)theIndex
{
	[self cutToEndOfLine:theIndex];
	[self insertBackward:theIndex];
}

- (void)changeToBeginningOfLine:(NSNumber *)theIndex
{
	[self cutToBeginningOfLine:theIndex];
	[self insertBackward:theIndex];
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
			//[self moveToBeginningOfLine:nil];
            [responder readSelectionFromPasteboard:pasteboard];
            [responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
			//[self moveToBeginningOfLine:nil];
        } else {
            //ViLog( @"pasteBefore as a string." );
            [responder readSelectionFromPasteboard:pasteboard];
            [responder performSelector: @selector(moveBackward:) withObject: window];
			//[self moveBackward:nil];
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
            //[responder performSelector: @selector(moveToEndOfLine:) withObject: window];
			[self moveToEndOfLine:nil];
            [responder insertText:str];
            //[responder performSelector: @selector(moveToBeginningOfLine:) withObject: window];
			[self moveToBeginningOfLine:nil];
        } else {
            //ViLog( @"pasteAfter as a string." );
			if ( ! [responder hasSelection] ) {
            	[self moveForward:nil];
			}

            [responder readSelectionFromPasteboard:pasteboard];
            [responder performSelector: @selector(moveBackward:) withObject: window];
			//[self moveBackward:nil];
        }
    }
     
    [router setActiveKeyMap:@"commandDefault"];
    [router setState:ViCommandState];
}





/**
 * Movement Methods
 */
- (void)moveForward:(NSNumber *)theIndex
{
    int line = [lineNumber intValue];

    [responder performSelector: @selector(moveForward:) withObject: window];

    if ( [lineNumber intValue] > line ) {
        [responder performSelector: @selector(moveBackward:) withObject: window];
    }
}

- (void)moveBackward:(NSNumber *)theIndex
{
    if ( [columnNumber intValue] > 0 ) {
        [responder performSelector: @selector(moveBackward:) withObject: window];
    }
}

- (void)moveUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveUp:) withObject: window];
}

- (void)moveDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveDown:) withObject: window];
}

- (void)moveWordBackward:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordBackward:) withObject: window];
}

- (void)moveWordForward:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordForward:) withObject: window];
    [responder performSelector: @selector(moveWordForward:) withObject: window];
    [responder performSelector: @selector(moveWordBackward:) withObject: window];
}

- (void)moveToEndOfWord:(NSNumber *)theIndex
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





/**
 * Visual Movement Methods
 */
- (void)moveForwardAndModifySelection:(NSNumber *)theIndex
{
    int line = [lineNumber intValue];

    [responder performSelector: @selector(moveForwardAndModifySelection:) withObject: window];

    if ( [lineNumber intValue] > line ) {
        [responder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
    }
}

- (void)moveBackwardAndModifySelection:(NSNumber *)theIndex
{
    if ( [columnNumber intValue] > 0 ) {
        [responder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
    }
}

- (void)moveUpAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveUpAndModifySelection:) withObject: window];
}

- (void)moveDownAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveDownAndModifySelection:) withObject: window];
}

- (void)moveWordBackwardAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordBackwardAndModifySelection:) withObject: window];
}

- (void)moveWordForwardAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordForwardAndModifySelection:) withObject: window];
    [responder performSelector: @selector(moveWordForwardAndModifySelection:) withObject: window];
    [responder performSelector: @selector(moveWordBackwardAndModifySelection:) withObject: window];
}

- (void)moveToEndOfWordAndModifySelection:(NSNumber *)theIndex
{
    [responder performSelector: @selector(moveWordForwardAndModifySelection:) withObject: window];
}





/**
 * Scroll Methods
 */
- (void)scrollLineUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(scrollLineUp:) withObject: window];
}

- (void)scrollLineDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(scrollLineDown:) withObject: window];
}

- (void)scrollHalfPageUp:(NSNumber *)theIndex
{
    //ViLog( @"height: %@", [window frame] );
}

- (void)scrollHalfPageDown:(NSNumber *)theIndex
{
    //ViLog( @"trying to determine height" );
    //ViLog( @"height: %@", [window frame] );
    //float height = [window frame].size.height;
    //ViLog( @"height: %@", height );
    //[responder scrollViewByX:0.0 byY: 1.0];
}

- (void)scrollPageUp:(NSNumber *)theIndex
{
    [responder performSelector: @selector(pageUp:) withObject: window];
}

- (void)scrollPageDown:(NSNumber *)theIndex
{
    [responder performSelector: @selector(pageDown:) withObject: window];
}




- (void)undo:(NSNumber *)theIndex
{
    //[responder undo];
}

@end
