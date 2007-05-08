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
        /**
         * The following 'command' keymaps are used for the standard command mode.
         * This map is used most often of the keymaps.  It is used at the following times:
         *   - when first entering command mode.
         *   - after the completion of a command sequence. e.x. d 4 w  (cut four words right)
         *   - whenever the state is reset by pressing the escape key.
         */
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                  @"controlDefault:", @"NSControlKeyMask",
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
                        @"cutRight:", @"x",
                         @"cutLeft:", @"X", 
                             @"cut:", @"d", 
                  @"cutToEndOfLine:", @"D", 
                          @"visual:", @"v",
                      NULL] forKey: @"commandDefault"];
        /**
         * This keymap restricts commands to those only those that work with a repeat 
         * command.  The primary difference with this keymap vs. the commandDefault 
         * keymap (asside from fewer commands) is that this one designates "0" 
         * as a repeat integer while the comandDefault map assigns "0" to the 
         * moveToBeginningOfLine command.
         */
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                  @"controlDefault:", @"NSControlKeyMask",
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
                        @"cutRight:", @"x",
                         @"cutLeft:", @"X",
                      NULL] forKey: @"commandRepeat"];
        /**
         * The cutDefault keymap is responsible for handling the "cut" mode
         * as in "cut, copy, and paste".  This keymap becomes the primary after 
         * pressing the "d" key once.  It removes commands from the commandDefault
         * keymap that cannot be used with the cut functionality.
         */
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
                         @"cutLeft:", @"h",
                         @"cutDown:", @"j",
                           @"cutUp:", @"k",
                        @"cutRight:", @"l",
            @"cutToBeginningOfLine:", @"0",
                  @"cutToEndOfLine:", @"$",
                     @"cutWordLeft:", @"b",
                    @"cutWordRight:", @"w",
                         @"cutLine:", @"d", 
                      NULL] forKey: @"cutDefault"];
        /**
         * This keymap restricts commands to those only those that work with a repeat 
         * command during a cut operation.  The primary difference with this keymap 
         * vs. the commandDefault keymap (asside from fewer commands) is that this
         * one designates "0" as a repeat integer while the comandDefault map assigns
         * "0" to the moveToBeginningOfLine command.
         */
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
                         @"cutLeft:", @"h",
                         @"cutDown:", @"j",
                           @"cutUp:", @"k",
                        @"cutRight:", @"l",
                  @"cutToEndOfLine:", @"$",
                     @"cutWordLeft:", @"b",
                    @"cutWordRight:", @"w",
                         @"cutLine:", @"d", 
                      NULL] forKey: @"cutRepeat"];
        /**
         * The copyDefault keymap is responsible for handling the "copy" mode
         * as in "cut, copy, and paste".  This keymap becomes the primary after 
         * pressing the "y" key once.  It removes commands from the commandDefault
         * keymap that cannot be used with the cut functionality.
         */
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
                        @"copyLeft:", @"h",
                        @"copyDown:", @"j",
                          @"copyUp:", @"k",
                       @"copyRight:", @"l",
           @"copyToBeginningOfLine:", @"0",
                 @"copyToEndOfLine:", @"$",
                    @"copyWordLeft:", @"b",
                   @"copyWordRight:", @"w",
                        @"copyLine:", @"y", 
                      NULL] forKey: @"copyDefault"];
        /**
         * This keymap restricts commands to those only those that work with a repeat 
         * command during a copy operation.  The primary difference with this keymap 
         * vs. the commandDefault keymap (asside from fewer commands) is that this
         * one designates "0" as a repeat integer while the comandDefault map assigns
         * "0" to the moveToBeginningOfLine command.
         */
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
                        @"copyLeft:", @"h",
                        @"copyDown:", @"j",
                          @"copyUp:", @"k",
                       @"copyRight:", @"l",
                 @"copyToEndOfLine:", @"$",
                    @"copyWordLeft:", @"b",
                   @"copyWordRight:", @"w",
                        @"copyLine:", @"y", 
                      NULL] forKey: @"copyRepeat"];
        /**
         * This keymap handles the commands that work with the control key modifier.
         * When an event comes in with a control key modifier, this is the map
         * that is used.
         */
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                          @"pageUp:", @"b",
                        @"pageDown:", @"f",
                    @"scrollLineUp:", @"y",
                  @"scrollLineDown:", @"e",
                      NULL] forKey: @"controlModifierDefault"];

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
            commandMethod = [[self keyMapWithEvent:theEvent] objectForKey: keyPress];

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
 * Sets and returns the active key map with influence of the event.
 * If there are modifier keys pressed (such as the control key)
 * then it may change the key map if the current state allows it.
 */
- (id)keyMapWithEvent:(NSEvent *)theEvent
{
    NSString * keyMapName;

    if ( ( [theEvent modifierFlags] & 0x0000FFFFU ) == 0 ) {

        if ( [theEvent modifierFlags] & NSControlKeyMask ) {
            keyMapName = [activeKeyMap objectForKey:@"NSControlKeyMask"];
        }

        if ( keyMapName == nil ) {
            keyMapName = @"commandDefault";
        }
        
        [self setKeyMap:keyMapName];
    } 

    return activeKeyMap;
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
