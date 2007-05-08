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
- (void)insert:(id)theEvent;
- (void)insertAtBeginningOfLine:(id)theEvent;
- (void)append:(id)theEvent;
- (void)appendToEndOfLine:(id)theEvent;

- (void)cut:(id)theEvent;
- (void)cutLine:(id)theEvent;
- (void)cutRight:(id)theEvent;
- (void)cutLeft:(id)theEvent;

/**
 * NSResponder methods
 */
- (void)cutToEndOfLine:(id)theEvent;
- (void)moveDown:(id)theEvent;
- (void)moveDownAndModifySelection:(id)theEvent;
- (void)moveLeft:(id)theEvent;
- (void)moveLeftAndModifySelection:(id)theEvent;
- (void)moveRight:(id)theEvent;
- (void)moveRightAndModifySelection:(id)theEvent;
- (void)moveToBeginningOfDocument:(id)theEvent;
- (void)moveToBeginningOfLine:(id)theEvent;
- (void)moveToEndOfDocument:(id)theEvent;
- (void)moveToEndOfLine:(id)theEvent;
- (void)moveUp:(id)theEvent;
- (void)moveUpAndModifySelection:(id)theEvent;
- (void)pageDown:(id)theEvent;
- (void)pageUp:(id)theEvent;
- (void)scrollLineDown:(id)theEvent;
- (void)scrollLineUp:(id)theEvent;

@end
