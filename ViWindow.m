//
//  ViWindow.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViWindow.h"
//#import "ViSelectorTest.h"
#import "ViCommandPanelController.h"

bool debugOn = FALSE;

@implementation ViWindow


- (BOOL)isValidWindowType:(NSWindow *)theWindow
{
	return [[theWindow firstResponder] isKindOfClass:NSClassFromString(@"OakTextView")];
}


- (void)sendEvent:(NSEvent *)theEvent
{
	id event;
	
	if( [self isValidWindowType:self] && [theEvent type] == NSKeyDown ) {
		NSString * keyPress = [theEvent charactersIgnoringModifiers];
		if ( [keyPress characterAtIndex:0] == 0x1B ){
		// if ( [keyPress characterAtIndex:0] == '`' ) {
			[[ViCommandPanelController sharedViCommandPanelController] handleInputAction:self];
		}
		// if ( [keyPress characterAtIndex:0] == ' ')
		// {
		// 	if ([theEvent modifierFlags]&NSShiftKeyMask)
		// 		[[ViCommandPanelController sharedViCommandPanelController] handleInputAction:self];
		// 	else 
		// 		[super sendEvent:theEvent];
		// }
		else {
				[super sendEvent:theEvent];
		} 
	}
	else {
			[super sendEvent:theEvent];
	}
}

@end
