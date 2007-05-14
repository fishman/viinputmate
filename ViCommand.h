//
//  ViCommand.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViExecution.h"


@interface ViCommand : NSObject {
    NSMutableArray *dataStack;
    NSMutableArray *methodStack;
    id router;
    ViExecution *execution;
}

- (void)setWindow:(NSWindow *)theWindow;
- (void)pushMethod:(NSString *)theMethod withData:(NSString *)theData;


/**
 * vi specific methods
 */
- (void)visual:(id)theEvent;
- (void)repeat:(id)theEvent;
- (void)resetStack:(id)theEvent;

/**
 * Insert Methods
 */
- (void)insertLeft:(id)theEvent;
- (void)insertRight:(id)theEvent;
- (void)insertAbove:(id)theEvent;
- (void)insertBelow:(id)theEvent;
- (void)insertAtBeginningOfLine:(id)theEvent;
- (void)insertAtEndOfLine:(id)theEvent;


/**
 * Cut Methods
 */
- (void)cut:(id)theEvent;
- (void)cutState:(id)theEvent;
- (void)cutLine:(id)theEvent;
- (void)cutRight:(id)theEvent;
- (void)cutLeft:(id)theEvent;
- (void)cutWordLeft:(id)theEvent;
- (void)cutWordRight:(id)theEvent;
- (void)cutToEndOfLine:(id)theEvent;
- (void)cutToBeginningOfLine:(id)theEvent;


/**
 * Copy Methods
 */
- (void)copy:(id)theEvent;
- (void)copyState:(id)theEvent;
- (void)copyLine:(id)theEvent;
- (void)copyRight:(id)theEvent;
- (void)copyLeft:(id)theEvent;
- (void)copyWordRight:(id)theEvent;
- (void)copyWordLeft:(id)theEvent;
- (void)copyToEndOfLine:(id)theEvent;
- (void)copyToBeginningOfLine:(id)theEvent;


/**
 * Paste Methods
 */
- (void)pasteBefore:(id)theEvent;
- (void)pasteAfter:(id)theEvent;


/**
 * Movement Methods
 */
- (void)moveDown:(id)theEvent;
- (void)moveDownAndModifySelection:(id)theEvent;
- (void)moveLeft:(id)theEvent;
- (void)moveLeftAndModifySelection:(id)theEvent;
- (void)moveRight:(id)theEvent;
- (void)moveRightAndModifySelection:(id)theEvent;
- (void)moveUp:(id)theEvent;
- (void)moveUpAndModifySelection:(id)theEvent;

- (void)moveWordBackward:(id)theEvent;
- (void)moveWordForward:(id)theEvent;

- (void)moveToBeginningOfLine:(id)theEvent;
- (void)moveToEndOfLine:(id)theEvent;

- (void)moveToBeginningOfDocument:(id)theEvent;
- (void)moveToEndOfDocument:(id)theEvent;

- (void)scrollPageDown:(id)theEvent;
- (void)scrollPageUp:(id)theEvent;

- (void)scrollHalfPageDown:(id)theEvent;
- (void)scrollHalfPageUp:(id)theEvent;

- (void)scrollLineDown:(id)theEvent;
- (void)scrollLineUp:(id)theEvent;

- (void)undo:(id)theEvent;

@end
