//
//  ViController.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViEditor.h"


@interface ViController : NSObject {
    bool repeatOn;
    NSMutableArray *dataStack;
    NSMutableArray *methodStack;
    id router;
    ViEditor *execution;
}

- (void)setWindow:(NSWindow *)theWindow;
- (void)releaseWindow:(NSWindow *)theWindow;
- (void)pushMethod:(NSString *)theMethod withData:(NSString *)theData;
- (void)setActiveKeyMap:(NSString *)theMapName;


/**
 * vi specific methods
 */
- (void)visual:(id)theEvent;
- (void)repeat:(id)theEvent;
- (void)resetStack:(id)theEvent;

/**
 * Insert Methods
 */
- (void)insertBackward:(id)theEvent;
- (void)insertForward:(id)theEvent;
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
- (void)cutForward:(id)theEvent;
- (void)cutBackward:(id)theEvent;
- (void)cutWordBackward:(id)theEvent;
- (void)cutWordForward:(id)theEvent;
- (void)cutToEndOfWord:(id)theEvent;
- (void)cutToEndOfLine:(id)theEvent;
- (void)cutToBeginningOfLine:(id)theEvent;


/**
 * Copy Methods
 */
- (void)copy:(id)theEvent;
- (void)copyState:(id)theEvent;
- (void)copyLine:(id)theEvent;
- (void)copyForward:(id)theEvent;
- (void)copyBackward:(id)theEvent;
- (void)copyWordForward:(id)theEvent;
- (void)copyWordBackward:(id)theEvent;
- (void)copyToEndOfWord:(id)theEvent;
- (void)copyToEndOfLine:(id)theEvent;
- (void)copyToBeginningOfLine:(id)theEvent;


/**
 * Change Methods
 */
- (void)change:(id)theEvent;
- (void)changeState:(id)theEvent;
- (void)changeLine:(id)theEvent;
- (void)changeForward:(id)theEvent;
- (void)changeBackward:(id)theEvent;
- (void)changeWordForward:(id)theEvent;
- (void)changeWordBackward:(id)theEvent;
- (void)changeToEndOfWord:(id)theEvent;
- (void)changeToEndOfLine:(id)theEvent;
- (void)changeToBeginningOfLine:(id)theEvent;


/**
 * Paste Methods
 */
- (void)pasteBefore:(id)theEvent;
- (void)pasteAfter:(id)theEvent;


/**
 * Movement Methods
 */
- (void)moveForward:(id)theEvent;
- (void)moveBackward:(id)theEvent;
- (void)moveUp:(id)theEvent;
- (void)moveDown:(id)theEvent;
- (void)moveWordBackward:(id)theEvent;
- (void)moveWordForward:(id)theEvent;
- (void)moveToEndOfWord:(id)theEvent;
- (void)moveToBeginningOfLine:(id)theEvent;
- (void)moveToEndOfLine:(id)theEvent;
- (void)moveToBeginningOfDocument:(id)theEvent;
- (void)moveToEndOfDocument:(id)theEvent;

/**
 * Visual Movement Methods
 */
- (void)moveForwardAndModifySelection:(id)theEvent;
- (void)moveBackwardAndModifySelection:(id)theEvent;
- (void)moveUpAndModifySelection:(id)theEvent;
- (void)moveDownAndModifySelection:(id)theEvent;
- (void)moveWordBackwardAndModifySelection:(id)theEvent;
- (void)moveWordForwardAndModifySelection:(id)theEvent;

/**
 * Scroll Methods
 */
- (void)scrollLineDown:(id)theEvent;
- (void)scrollLineUp:(id)theEvent;
- (void)scrollHalfPageDown:(id)theEvent;
- (void)scrollHalfPageUp:(id)theEvent;
- (void)scrollPageDown:(id)theEvent;
- (void)scrollPageUp:(id)theEvent;



- (void)undo:(id)theEvent;

@end
