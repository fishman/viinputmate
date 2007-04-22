//
//  ViWindow.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViWindow.h"
//#import "ViSelectorTest.h"
#import "ViEventRouter.h"


@implementation ViWindow

- (void)sendEvent:(NSEvent *)theEvent
{
    id event;
    ViEventRouter *router = [ViEventRouter sharedViEventRouter];
    
    if ( [theEvent type] == NSKeyDown ) {
        [router setWindow:self];
        event = [router routeEvent:theEvent];
            
        if ( event != nil ) {
            [super sendEvent:theEvent];
        } 
    } else {
        [super sendEvent:theEvent];
    }
}

@end
