//
//  ViEditor.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViEditor : NSObject {

    NSWindow * window;
    id responder;

    id router;
    NSMutableArray * dataStack;
    NSMutableArray * methodStack;
    NSNumber * lineNumber;
    NSNumber * columnNumber;
    NSPasteboard * pasteboard;
}

- (void)setLineNumber:(id)theLineNumber;
- (NSNumber *)lineNumber;
- (void)setColumnNumber:(id)theColumnNumber;
- (NSNumber *)columnNumber;

- (void)setWindow:(NSWindow *)theWindow;
- (void)releaseWindow:(NSWindow *)theWindow;
- (void)executeStack:(NSMutableArray *)theMethodStack 
            withData:(NSMutableArray *)theDataStack;


/**
 * vi specific methods
 */
- (void)visual:(NSNumber *)theIndex;
- (void)repeat:(NSNumber *)theIndex;
- (void)resetStack:(NSNumber *)theIndex;
- (void)insertBackward:(NSNumber *)theIndex;
- (void)insertForward:(NSNumber *)theIndex;
- (void)insertAbove:(NSNumber *)theIndex;
- (void)insertBelow:(NSNumber *)theIndex;
- (void)insertAtBeginningOfLine:(NSNumber *)theIndex;
- (void)insertAtEndOfLine:(NSNumber *)theIndex;

/**
 * Cut Methods
 */
- (void)cut:(NSNumber *)theIndex;
- (void)cutLine:(NSNumber *)theIndex;
- (void)cutForward:(NSNumber *)theIndex;
- (void)cutBackward:(NSNumber *)theIndex;
- (void)cutWordForward:(NSNumber *)theIndex;
- (void)cutWordBackward:(NSNumber *)theIndex;
- (void)cutToEndOfWord:(NSNumber *)theIndex;
- (void)cutToEndOfLine:(NSNumber *)theIndex;
- (void)cutToBeginningOfLine:(NSNumber *)theIndex;

/**
 * Copy Methods
 */
- (void)copy:(NSNumber *)theIndex;
- (void)copyLine:(NSNumber *)theIndex;
- (void)copyForward:(NSNumber *)theIndex;
- (void)copyBackward:(NSNumber *)theIndex;
- (void)copyWordForward:(NSNumber *)theIndex;
- (void)copyWordBackward:(NSNumber *)theIndex;
- (void)copyToEndOfWord:(NSNumber *)theIndex;
- (void)copyToEndOfLine:(NSNumber *)theIndex;
- (void)copyToBeginningOfLine:(NSNumber *)theIndex;

/**
 * Change Methods
 */
- (void)change:(NSNumber *)theIndex;
- (void)changeLine:(NSNumber *)theIndex;
- (void)changeForward:(NSNumber *)theIndex;
- (void)changeBackward:(NSNumber *)theIndex;
- (void)changeWordForward:(NSNumber *)theIndex;
- (void)changeWordBackward:(NSNumber *)theIndex;
- (void)changeToEndOfWord:(NSNumber *)theIndex;
- (void)changeToEndOfLine:(NSNumber *)theIndex;
- (void)changeToBeginningOfLine:(NSNumber *)theIndex;

/**
 * Paste Methods
 */
- (void)pasteBefore:(NSNumber *)theIndex;
- (void)pasteAfter:(NSNumber *)theIndex;


/**
 * Movement Methods
 */
- (void)moveForward:(NSNumber *)theIndex;
- (void)moveBackward:(NSNumber *)theIndex;
- (void)moveUp:(NSNumber *)theIndex;
- (void)moveDown:(NSNumber *)theIndex;
- (void)moveWordBackward:(NSNumber *)theIndex;
- (void)moveWordForward:(NSNumber *)theIndex;
- (void)moveToEndOfWord:(NSNumber *)theIndex;
- (void)moveToBeginningOfLine:(NSNumber *)theIndex;
- (void)moveToEndOfLine:(NSNumber *)theIndex;
- (void)moveToBeginningOfDocument:(NSNumber *)theIndex;
- (void)moveToEndOfDocument:(NSNumber *)theIndex;

/**
 * Visual Movement Methods
 */
- (void)moveForwardAndModifySelection:(NSNumber *)theIndex;
- (void)moveBackwardAndModifySelection:(NSNumber *)theIndex;
- (void)moveUpAndModifySelection:(NSNumber *)theIndex;
- (void)moveDownAndModifySelection:(NSNumber *)theIndex;
- (void)moveWordBackwardAndModifySelection:(NSNumber *)theIndex;
- (void)moveWordForwardAndModifySelection:(NSNumber *)theIndex;
- (void)moveToEndOfWordAndModifySelection:(NSNumber *)theIndex;

/**
 * Scroll Methods
 */
- (void)scrollPageDown:(NSNumber *)theIndex;
- (void)scrollPageUp:(NSNumber *)theIndex;

- (void)scrollHalfPageDown:(NSNumber *)theIndex;
- (void)scrollHalfPageUp:(NSNumber *)theIndex;

- (void)scrollLineDown:(NSNumber *)theIndex;
- (void)scrollLineUp:(NSNumber *)theIndex;

- (void)undo:(NSNumber *)theIndex;

@end
