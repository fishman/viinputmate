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
- (void)repeat:(id)theEvent;
- (void)resetStack:(id)theEvent;
- (void)insert:(id)theEvent;
- (void)insertAtBeginningOfLine:(id)theEvent;
- (void)append:(id)theEvent;
- (void)appendToEndOfLine:(id)theEvent;
- (void)delete:(id)theEvent;
- (void)deleteLine:(id)theEvent;
- (void)deleteRight:(id)theEvent;
- (void)deleteLeft:(id)theEvent;
- (void)visual:(id)theEvent;

/**
 * NSResponder methods
 */
- (void)changeCaseOfLetter:(id)theEvent;
- (void)deleteBackward:(id)theEvent;
- (void)deleteForward:(id)theEvent;
- (void)deleteToBeginningOfLine:(id)theEvent;
- (void)deleteToBeginningOfParagraph:(id)theEvent;
- (void)deleteToEndOfLine:(id)theEvent;
- (void)deleteToEndOfParagraph:(id)theEvent;
- (void)deleteToMark:(id)theEvent;
- (void)deleteWordBackward:(id)theEvent;
- (void)deleteWordForward:(id)theEvent;
- (void)indent:(id)theEvent;
- (void)insertBacktab:(id)theEvent;
- (void)insertContainerBreak:(id)theEvent;
- (void)insertLineBreak:(id)theEvent;
- (void)insertNewline:(id)theEvent;
- (void)insertNewlineIgnoringFieldEditor:(id)theEvent;
- (void)insertParagraphSeparator:(id)theEvent;
- (void)insertTab:(id)theEvent;
- (void)insertTabIgnoringFieldEditor:(id)theEvent;
- (void)insertText:(id)theEvent;
- (void)lowercaseWord:(id)theEvent;
- (void)moveBackward:(id)theEvent;
- (void)moveBackwardAndModifySelection:(id)theEvent;
- (void)moveDown:(id)theEvent;
- (void)moveDownAndModifySelection:(id)theEvent;
- (void)moveForward:(id)theEvent;
- (void)moveForwardAndModifySelection:(id)theEvent;
- (void)moveLeft:(id)theEvent;
- (void)moveLeftAndModifySelection:(id)theEvent;
- (void)moveRight:(id)theEvent;
- (void)moveRightAndModifySelection:(id)theEvent;
- (void)moveToBeginningOfDocument:(id)theEvent;
- (void)moveToBeginningOfLine:(id)theEvent;
- (void)moveToBeginningOfParagraph:(id)theEvent;
- (void)moveToEndOfDocument:(id)theEvent;
- (void)moveToEndOfLine:(id)theEvent;
- (void)moveToEndOfParagraph:(id)theEvent;
- (void)moveUp:(id)theEvent;
- (void)moveUpAndModifySelection:(id)theEvent;
- (void)pageDown:(id)theEvent;
- (void)pageUp:(id)theEvent;
- (void)scrollLineDown:(id)theEvent;
- (void)scrollLineUp:(id)theEvent;
- (void)scrollPageDown:(id)theEvent;
- (void)scrollPageUp:(id)theEvent;
- (void)selectAll:(id)theEvent;
- (void)selectLine:(id)theEvent;
- (void)selectParagraph:(id)theEvent;
- (void)selectToMark:(id)theEvent;
- (void)selectWord:(id)theEvent;
- (void)setMark:(id)theEvent;
- (void)showContextHelp:(id)theEvent;
- (void)swapWithMark:(id)theEvent;
- (void)uppercaseWord:(id)theEvent;
- (void)yank:(id)theEvent;

@end
