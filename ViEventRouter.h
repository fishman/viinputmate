//
//  ViEventRouter.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "ViCommandStack.h"
#import "ViCommand.h"

extern bool debugOn;

typedef enum _ViMode {
    ViInsertMode       = 1,
    ViCommandMode      = 2,
} ViMode;

typedef enum _ViState {
    ViCommandState       = 1,
    ViDeleteState        = 2,
    ViYankState          = 3,
    ViVisualState        = 4
} ViState;


@interface ViEventRouter : NSObject
{
    ViMode mode;
    ViState state;
    NSWindow * lastWindow;
    id responder;
    // holds onto the methods that should be executed once we reach a final method.
    ViCommand *command;
    NSMutableDictionary *keyMaps;
    id activeKeyMap;
}

// methods needed for singleton pattern
+ (ViEventRouter *)sharedViEventRouter;
+ (id)allocWithZone:(NSZone *)zone;
- (id)init;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;

// methods we actually need to use
- (NSEvent *)routeEvent:(NSEvent *)theEvent;
- (void)setActiveKeyMap:(NSString *)theKeyMapLabel;
- (id)keyMapWithEvent:(NSEvent *)theEvent;
- (id)eventPassThrough:(NSEvent *)theEvent;
- (void)setMode:(ViMode)theMode;
- (ViMode)mode;
- (void)setState:(ViState)theState;
- (ViState)state;
- (void)setWindow:(NSWindow *)theWindow;

@end
