//
//  ViWindow.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViPlugin.h"


@interface ViWindow : NSWindow {

}

- (void)sendEvent:(NSEvent *)theEvent;

@end
