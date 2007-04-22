//
//  ViExecution.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViExecution : NSObject {

    NSWindow *window;
    id responder;

    id router;
    NSMutableArray *dataStack;
    NSMutableArray *methodStack;
}


- (void)executeStack:(NSMutableArray *)theMethodStack 
            withData:(NSMutableArray *)theDataStack;
- (void)setWindow:(NSWindow *)theWindow;


/**
 * vi specific methods
 */
- (void)repeat:(NSNumber *)theIndex;
- (void)resetStack:(NSNumber *)theIndex;
- (void)insert:(NSNumber *)theIndex;
- (void)insertAtBeginningOfLine:(NSNumber *)theIndex;
- (void)append:(NSNumber *)theIndex;
- (void)appendToEndOfLine:(NSNumber *)theIndex;
- (void)delete:(NSNumber *)theIndex;
- (void)deleteLine:(NSNumber *)theIndex;
- (void)deleteRight:(NSNumber *)theIndex;
- (void)deleteLeft:(NSNumber *)theIndex;
- (void)visual:(NSNumber *)theIndex;


/**
 * NSResponder methods
 */
- (void)changeCaseOfLetter:(NSNumber *)theIndex;
- (void)deleteBackward:(NSNumber *)theIndex;
- (void)deleteForward:(NSNumber *)theIndex;
- (void)deleteToBeginningOfLine:(NSNumber *)theIndex;
- (void)deleteToBeginningOfParagraph:(NSNumber *)theIndex;
- (void)deleteToEndOfLine:(NSNumber *)theIndex;
- (void)deleteToEndOfParagraph:(NSNumber *)theIndex;
- (void)deleteToMark:(NSNumber *)theIndex;
- (void)deleteWordBackward:(NSNumber *)theIndex;
- (void)deleteWordForward:(NSNumber *)theIndex;
- (void)indent:(NSNumber *)theIndex;
- (void)insertBacktab:(NSNumber *)theIndex;
- (void)insertContainerBreak:(NSNumber *)theIndex;
- (void)insertLineBreak:(NSNumber *)theIndex;
- (void)insertNewline:(NSNumber *)theIndex;
- (void)insertNewlineIgnoringFieldEditor:(NSNumber *)theIndex;
- (void)insertParagraphSeparator:(NSNumber *)theIndex;
- (void)insertTab:(NSNumber *)theIndex;
- (void)insertTabIgnoringFieldEditor:(NSNumber *)theIndex;
- (void)insertText:(NSNumber *)theIndex;
- (void)lowercaseWord:(NSNumber *)theIndex;
- (void)moveBackward:(NSNumber *)theIndex;
- (void)moveBackwardAndModifySelection:(NSNumber *)theIndex;
- (void)moveDown:(NSNumber *)theIndex;
- (void)moveDownAndModifySelection:(NSNumber *)theIndex;
- (void)moveForward:(NSNumber *)theIndex;
- (void)moveForwardAndModifySelection:(NSNumber *)theIndex;
- (void)moveLeft:(NSNumber *)theIndex;
- (void)moveLeftAndModifySelection:(NSNumber *)theIndex;
- (void)moveRight:(NSNumber *)theIndex;
- (void)moveRightAndModifySelection:(NSNumber *)theIndex;
- (void)moveToBeginningOfDocument:(NSNumber *)theIndex;
- (void)moveToBeginningOfLine:(NSNumber *)theIndex;
- (void)moveToBeginningOfParagraph:(NSNumber *)theIndex;
- (void)moveToEndOfDocument:(NSNumber *)theIndex;
- (void)moveToEndOfLine:(NSNumber *)theIndex;
- (void)moveToEndOfParagraph:(NSNumber *)theIndex;
- (void)moveUp:(NSNumber *)theIndex;
- (void)moveUpAndModifySelection:(NSNumber *)theIndex;
- (void)pageDown:(NSNumber *)theIndex;
- (void)pageUp:(NSNumber *)theIndex;
- (void)scrollLineDown:(NSNumber *)theIndex;
- (void)scrollLineUp:(NSNumber *)theIndex;
- (void)scrollPageDown:(NSNumber *)theIndex;
- (void)scrollPageUp:(NSNumber *)theIndex;
- (void)selectAll:(NSNumber *)theIndex;
- (void)selectLine:(NSNumber *)theIndex;
- (void)selectParagraph:(NSNumber *)theIndex;
- (void)selectToMark:(NSNumber *)theIndex;
- (void)selectWord:(NSNumber *)theIndex;
- (void)setMark:(NSNumber *)theIndex;
- (void)showContextHelp:(NSNumber *)theIndex;
- (void)swapWithMark:(NSNumber *)theIndex;
- (void)uppercaseWord:(NSNumber *)theIndex;
- (void)yank:(NSNumber *)theIndex;

@end
