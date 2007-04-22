//
//  ViSelectorTest.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViSelectorTest.h"


@implementation ViSelectorTest

+ (NSEvent *)handleEvent:(NSEvent *)theEvent 
            withResponder:(id)theResponder 
               withWindow:(NSWindow *)theWindow
{
    switch ( [[theEvent charactersIgnoringModifiers] characterAtIndex:0 ] ) {
        case 'h':
            [theResponder performSelector: @selector(moveLeft:) withObject: theWindow];
            break;        
        case 'j':
            [theResponder performSelector: @selector(moveDown:) withObject: theWindow];
            break;        
        case 'k':
            [theResponder performSelector: @selector(moveUp:) withObject: theWindow];
            break;        
        case 'l':
            [theResponder performSelector: @selector(moveRight:) withObject: theWindow];
            break;        
        case '0':
            [theResponder performSelector: @selector(moveToBeginningOfLine:) withObject: theWindow];
            break;        
        case '$':
            [theResponder performSelector: @selector(moveToEndOfLine:) withObject: theWindow];
            break;        
        default:
            return theEvent;
    }
    
    return nil;
}

@end
