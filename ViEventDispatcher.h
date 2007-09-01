//
//  ViEventDispatcher.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViController.h"
#import "ViView.h"
#import "ViMode.h"

extern bool debugOn;



typedef enum _ViState {
    ViCommandState       = 1,
    ViVisualState        = 2,
    ViCutState           = 3,
    ViCopyState          = 4,
    ViChangeState        = 5
} ViState;


@interface ViEventDispatcher : NSObject
{
    ViMode mode;
    ViState state;
    NSWindow * lastWindow;
    id responder;
    // holds onto the methods that should be executed once we reach a final method.
    ViController *command;
    NSMutableDictionary *keyMaps;
    id activeKeyMap;
	
	ViView * currentCursorView;
}

// methods needed for singleton pattern
+ (ViEventDispatcher *)sharedViEventDispatcher;
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
- (void)releaseWindow:(NSWindow *)theWindow;

@end
