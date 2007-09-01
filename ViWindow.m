//
//  ViWindow.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViWindow.h"
//#import "ViSelectorTest.h"
#import "ViEventDispatcher.h"


@implementation ViWindow


+ (BOOL)isValidWindowType:(NSWindow *)theWindow
{
	return [[theWindow firstResponder] isKindOfClass:NSClassFromString(@"OakTextView")];
}

-(void)dealloc
{
	ViLog( @"[ViWindow %s]", _cmd );
	
	if( [ViWindow isValidWindowType:self] ){
		ViEventDispatcher *router = [ViEventDispatcher sharedViEventDispatcher];
		[router releaseWindow:self];
	}
	[super dealloc];
}

- (void)sendEvent:(NSEvent *)theEvent
{
    id event;
	
	if( [ViWindow isValidWindowType:self] && [theEvent type] == NSKeyDown ) {
		ViEventDispatcher *router = [ViEventDispatcher sharedViEventDispatcher];
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
