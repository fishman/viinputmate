//
//  ViEventRouter.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViEventRouter.h"


static ViEventRouter *sharedViEventRouter = nil;

/**
 * singleton instance of the event router.
 *
 * @return the ViEventRouter instance
 */
@implementation ViEventRouter
+ (ViEventRouter *)sharedViEventRouter
{

    if (sharedViEventRouter == nil) {
        [[self alloc] init];
    }
    
    return sharedViEventRouter;
}

/**
 * Part of the singleton pattern.
 */
+ (id)allocWithZone:(NSZone *)zone
{
    if (sharedViEventRouter == nil) {
        sharedViEventRouter = [super allocWithZone:zone];

        return sharedViEventRouter ;  // assignment and return on first allocation
    }
    
    return nil; // on subsequent allocation attempts return nil
}

- (id)init
{
    unichar escape = 0x1B;

    if ((self = [super init])) {
        mode = ViInsertMode;
        command = [[ViCommand alloc] init];


        keyMaps = [NSMutableDictionary dictionaryWithCapacity:2];
        [keyMaps retain];
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                      @"resetStack:", [NSString stringWithCharacters:&escape length:1],
                          @"repeat:", @"1",
                          @"repeat:", @"2",
                          @"repeat:", @"3",
                          @"repeat:", @"4",
                          @"repeat:", @"5",
                          @"repeat:", @"6",
                          @"repeat:", @"7",
                          @"repeat:", @"8",
                          @"repeat:", @"9",
                        @"moveLeft:", @"h",
                        @"moveDown:", @"j",
                          @"moveUp:", @"k",
                       @"moveRight:", @"l",
           @"moveToBeginningOfLine:", @"0",
                 @"moveToEndOfLine:", @"$",
                          @"insert:", @"i",
         @"insertAtBeginningOfLine:", @"I",
                          @"append:", @"a",
               @"appendToEndOfLine:", @"A",
                     @"deleteRight:", @"x",
                      @"deleteLeft:", @"X", 
                            @"delete:", @"d", 
               @"deleteToEndOfLine:", @"D", 
                          @"visual:", @"v",
                      NULL] forKey: @"commandDefault"];
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                      @"resetStack:", [NSString stringWithCharacters:&escape length:1],
                          @"repeat:", @"0",
                          @"repeat:", @"1",
                          @"repeat:", @"2",
                          @"repeat:", @"3",
                          @"repeat:", @"4",
                          @"repeat:", @"5",
                          @"repeat:", @"6",
                          @"repeat:", @"7",
                          @"repeat:", @"8",
                          @"repeat:", @"9",
                        @"moveLeft:", @"h",
                        @"moveDown:", @"j",
                          @"moveUp:", @"k",
                       @"moveRight:", @"l",
                          @"insert:", @"i",
         @"insertAtBeginningOfLine:", @"I",
                          @"append:", @"a",
               @"appendToEndOfLine:", @"A",
                     @"deleteRight:", @"x",
                      @"deleteLeft:", @"X",
                      NULL] forKey: @"commandRepeat"];
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                      @"resetStack:", [NSString stringWithCharacters:&escape length:1],
                          @"repeat:", @"1",
                          @"repeat:", @"2",
                          @"repeat:", @"3",
                          @"repeat:", @"4",
                          @"repeat:", @"5",
                          @"repeat:", @"6",
                          @"repeat:", @"7",
                          @"repeat:", @"8",
                          @"repeat:", @"9",
                      @"deleteLeft:", @"h",
                      @"deleteDown:", @"j",
                        @"deleteUp:", @"k",
                     @"deleteRight:", @"l",
         @"deleteToBeginningOfLine:", @"0",
               @"deleteToEndOfLine:", @"$",
                  @"deleteWordLeft:", @"b",
                 @"deleteWordRight:", @"w",
                      @"deleteLine:", @"d", 
                      NULL] forKey: @"deleteDefault"];
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                      @"resetStack:", [NSString stringWithCharacters:&escape length:1],
                          @"repeat:", @"0",
                          @"repeat:", @"1",
                          @"repeat:", @"2",
                          @"repeat:", @"3",
                          @"repeat:", @"4",
                          @"repeat:", @"5",
                          @"repeat:", @"6",
                          @"repeat:", @"7",
                          @"repeat:", @"8",
                          @"repeat:", @"9",
                      @"deleteLeft:", @"h",
                      @"deleteDown:", @"j",
                        @"deleteUp:", @"k",
                     @"deleteRight:", @"l",
               @"deleteToEndOfLine:", @"$",
                  @"deleteWordLeft:", @"b",
                 @"deleteWordRight:", @"w",
                      @"deleteLine:", @"d", 
                      NULL] forKey: @"deleteRepeat"];

        activeKeyMap = [keyMaps objectForKey:@"commandDefault"];
    }

    return self;
}

/**
 * Part of the singleton pattern.
 */
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

/**
 * Part of the singleton pattern.
 */
- (id)retain
{
    return self;
}


/**
 * Recieves the keypress event and determines what to do about it
 * based on the mode and the current state.  
 *
 * @param NSEvent theEvent 
 * @return mixed If the event was handled by the plugin then nil
 * is returned.  If it was not handled here then it returns the event 
 * so that it can be passed down the event chain.
 */
- (NSEvent *)routeEvent:(NSEvent *)theEvent
{
    NSString * keyPress = [theEvent charactersIgnoringModifiers];
    NSString * commandMethod;

    switch ( mode ) {
        case ViInsertMode:
            // if escape is pressed.
            if ( [keyPress characterAtIndex:0] == 0x1B ) {
                mode = ViCommandMode;
                return nil;
            } else {
                return theEvent;
            }
            break;

        case ViVisualMode:
        case ViCommandMode:
            // find the method that corresponds to the key that was pressed 
            // given the current state's key map.
            commandMethod = [activeKeyMap objectForKey: keyPress];

            if ( commandMethod != nil ) {
                NSLog( @"routing the message" );
                [command performSelector: sel_getUid([commandMethod UTF8String]) withObject: theEvent];
                return nil;
            } else {
                NSLog( @"could not find method for %@:", keyPress );
                [command performSelector: @selector(resetStack:) withObject: theEvent];
                return nil;
            }

            break;
        default:
            return theEvent;
    }
}

/**
 * Sets the activeKeyMap to a different map.  This is how we
 * attempt to keep track of the states.
 */
- (void)setKeyMap:(NSString *)theKeyMapLabel
{
    activeKeyMap = [keyMaps objectForKey: theKeyMapLabel];
}

/**
 * Sets the mode
 */
- (void)setMode:(ViMode)theMode
{
    mode = theMode;
}

- (ViMode)mode
{
    return mode;
}

- (void)setState:(ViState)theState
{
    state = theState;
}

- (ViState)state
{
    return state;
}

- (void)setWindow:(NSWindow *)theWindow
{
    [command setWindow:theWindow];
}

@end
