//
//  ViEventDispatcher.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViEventDispatcher.h"
#import "ViHelper.h"
#import "ViWindow.h"

static ViEventDispatcher *sharedViEventDispatcher = nil;
bool debugOn = false;

/**
 * singleton instance of the event router.
 *
 * @return the ViEventDispatcher instance
 */
@implementation ViEventDispatcher
+ (ViEventDispatcher *)sharedViEventDispatcher
{

    if (sharedViEventDispatcher == nil) {
        [[self alloc] init];
    }
    
    return sharedViEventDispatcher;
}

/**
 * Part of the singleton pattern.
 */
+ (id)allocWithZone:(NSZone *)zone
{
    if (sharedViEventDispatcher == nil) {
        sharedViEventDispatcher = [super allocWithZone:zone];

        return sharedViEventDispatcher ;  // assignment and return on first allocation
    }
    
    return nil; // on subsequent allocation attempts return nil
}

- (id)init
{
    unichar escape = 0x1B;

    if ((self = [super init])) {
        lastWindow = nil;
		currentCursorView = nil;
        mode = ViInsertMode;
        command = [[ViController alloc] init];


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
		                   @"controlDefault", @"NSControlKeyMask",
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
		                    @"moveBackward:", @"h",
		                        @"moveDown:", @"j",
		                          @"moveUp:", @"k",
		                     @"moveForward:", @"l",
		                @"moveWordBackward:", @"b",
		                 @"moveWordForward:", @"w",
		                 @"moveToEndOfWord:", @"e",
		           @"moveToBeginningOfLine:", @"0",
		                 @"moveToEndOfLine:", @"$",
		             @"moveToEndOfDocument:", @"G",
		                  @"insertBackward:", @"i",
		                   @"insertForward:", @"a",
							 @"insertAbove:", @"O",
							 @"insertBelow:", @"o",
		         @"insertAtBeginningOfLine:", @"I",
		               @"insertAtEndOfLine:", @"A",
		                        @"cutState:", @"d", 
		                      @"cutForward:", @"x",
		                     @"cutBackward:", @"X", 
		                  @"cutToEndOfLine:", @"D", 
		                       @"copyState:", @"y", 
		               @"changeToEndOfLine:", @"C", 
		                     @"changeState:", @"c", 
                           @"changeForward:", @"s", 
		                     @"pasteBefore:", @"P", 
		                      @"pasteAfter:", @"p", 
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
		                   @"controlDefault", @"NSControlKeyMask",
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
		                    @"moveBackward:", @"h",
		                        @"moveDown:", @"j",
		                          @"moveUp:", @"k",
		                     @"moveForward:", @"l",
		                @"moveWordBackward:", @"b",
		                 @"moveWordForward:", @"w",
		                 @"moveToEndOfWord:", @"e",
		                  @"insertBackward:", @"i",
		         @"insertAtBeginningOfLine:", @"I",
		                   @"insertForward:", @"a",
		               @"insertAtEndOfLine:", @"A",
		                     @"pasteBefore:", @"P", 
		                      @"pasteAfter:", @"p", 
		                      @"cutForward:", @"x",
		                     @"cutBackward:", @"X",
                      NULL] forKey: @"commandRepeat"];

        /**
         * The visual mode keymap.  I was hoping that I would not need
         * to do this and to solve all of the visual mode trickery 
         * with marks.  But alas, TextMate does not implement marks.
         */
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
                           @"controlDefault", @"NSControlKeyMask",
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
          @"moveBackwardAndModifySelection:", @"h",
              @"moveDownAndModifySelection:", @"j",
                @"moveUpAndModifySelection:", @"k",
           @"moveForwardAndModifySelection:", @"l",
       @"moveWordForwardAndModifySelection:", @"w",
      @"moveWordBackwardAndModifySelection:", @"b",
       @"moveToEndOfWordAndModifySelection:", @"e",
                          @"insertBackward:", @"i",
                 @"insertAtBeginningOfLine:", @"I",
                           @"insertForward:", @"A",
                                     @"cut:", @"d",
                              @"cutForward:", @"x",
                                 @"cutLine:", @"X", 
                              @"cutForward:", @"d", 
                                 @"cutLine:", @"D", 
                                    @"copy:", @"y",
                             @"pasteBefore:", @"P", 
                              @"pasteAfter:", @"p", 
                      NULL] forKey: @"visualDefault"];

        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
		                   @"controlDefault", @"NSControlKeyMask",
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
		  @"moveBackwardAndModifySelection:", @"h",
		      @"moveDownAndModifySelection:", @"j",
		        @"moveUpAndModifySelection:", @"k",
		   @"moveForwardAndModifySelection:", @"l",
       @"moveWordForwardAndModifySelection:", @"w",
      @"moveWordBackwardAndModifySelection:", @"b",
       @"moveToEndOfWordAndModifySelection:", @"e",
		                  @"insertBackward:", @"i",
		         @"insertAtBeginningOfLine:", @"I",
		                   @"insertForward:", @"A",
		                      @"cutForward:", @"x",
		                         @"cutLine:", @"X", 
		                      @"cutForward:", @"d", 
		                         @"cutLine:", @"D", 
		                     @"pasteBefore:", @"P", 
                      NULL] forKey: @"visualRepeat"];
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
		                     @"cutBackward:", @"h",
		                         @"cutDown:", @"j",
		                           @"cutUp:", @"k",
		                      @"cutForward:", @"l",
		            @"cutToBeginningOfLine:", @"0",
		                  @"cutToEndOfLine:", @"$",
		                  @"cutWordForward:", @"w",
		                 @"cutWordBackward:", @"b",
		                  @"cutToEndOfWord:", @"e",
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
		                     @"cutBackward:", @"h",
		                         @"cutDown:", @"j",
		                           @"cutUp:", @"k",
		                      @"cutForward:", @"l",
		                  @"cutToEndOfLine:", @"$",
		                  @"cutWordForward:", @"w",
		                 @"cutWordBackward:", @"b",
		                  @"cutToEndOfWord:", @"e",
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
		                    @"copyBackward:", @"h",
		                        @"copyDown:", @"j",
		                          @"copyUp:", @"k",
		                     @"copyForward:", @"l",
		           @"copyToBeginningOfLine:", @"0",
		                 @"copyToEndOfLine:", @"$",
		                 @"copyWordForward:", @"w",
		                @"copyWordBackward:", @"b",
		                 @"copyToEndOfWord:", @"e",
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
		                    @"copyBackward:", @"h",
		                        @"copyDown:", @"j",
		                          @"copyUp:", @"k",
		                     @"copyForward:", @"l",
		                 @"copyToEndOfLine:", @"$",
		                 @"copyWordForward:", @"w",
		                @"copyWordBackward:", @"b",
		                 @"copyToEndOfWord:", @"e",
		                        @"copyLine:", @"y", 
                      NULL] forKey: @"copyRepeat"];
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
		                  @"changeBackward:", @"h",
		                      @"changeDown:", @"j",
		                        @"changeUp:", @"k",
		                   @"changeForward:", @"l",
		         @"changeToBeginningOfLine:", @"0",
		               @"changeToEndOfLine:", @"$",
		               @"changeWordForward:", @"w",
		              @"changeWordBackward:", @"b",
		               @"changeToEndOfWord:", @"e",
		                      @"changeLine:", @"c", 
                      NULL] forKey: @"changeDefault"];
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
		                  @"changeBackward:", @"h",
		                      @"changeDown:", @"j",
		                        @"changeUp:", @"k",
		                   @"changeForward:", @"l",
		               @"changeToEndOfLine:", @"$",
		               @"changeWordForward:", @"w",
		              @"changeWordBackward:", @"b",
		               @"changeToEndOfWord:", @"e",
		                      @"changeLine:", @"d", 
                      NULL] forKey: @"changeRepeat"];
        /**
         * This keymap handles the commands that work with the control key modifier.
         * When an event comes in with a control key modifier, this is the map
         * that is used.
         */
        [keyMaps setObject: [NSDictionary dictionaryWithObjectsAndKeys:
		                   @"controlDefault", @"NSControlKeyMask",
		                    @"scrollPageUp:", @"b",
		                  @"scrollPageDown:", @"f",
		                @"scrollHalfPageUp:", @"u",
		              @"scrollHalfPageDown:", @"d",
		                    @"scrollLineUp:", @"y",
		                  @"scrollLineDown:", @"e",
                      NULL] forKey: @"controlDefault"];

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
                [self setMode:ViCommandMode];
                [self setState:ViCommandState];

                // if the a selection was made in insert mode. clear it
                // before entering command mode.
                if ( [responder hasSelection] ) {
                    [responder performSelector: @selector(moveBackward:) withObject: lastWindow];
                }

                return nil;
            } else {
                return theEvent;
            }
            break;

        case ViCommandMode:
            // find the method that corresponds to the key that was pressed 
            // given the current state's key map.
            commandMethod = [[self keyMapWithEvent:theEvent] objectForKey: keyPress];

            if ( commandMethod != nil ) {
                //ViLog( @"routing the message: %@", commandMethod );
                [command performSelector: sel_getUid([commandMethod UTF8String]) withObject: theEvent];
                return nil;
            } else {
                // test for modifier keys down
                // test for delete key
                //ViLog( @"cannot route the message" );
                [command performSelector: @selector(resetStack:) withObject: theEvent];
                return [self eventPassThrough:theEvent];
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
- (void)setActiveKeyMap:(NSString *)theKeyMapLabel
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

    if ( ( [theEvent modifierFlags] & NSControlKeyMask ) != 0 ) {
        keyMapName = [activeKeyMap objectForKey:@"NSControlKeyMask"];
        [self setActiveKeyMap:keyMapName];
    }

    return activeKeyMap;
}

- (id)eventPassThrough:(NSEvent *)theEvent
{
    NSString * keyPress = [theEvent charactersIgnoringModifiers];

    if ( ( [theEvent modifierFlags] & 0x0000FFFFU ) == 0 ) {
        return theEvent;
    }

    switch ( [keyPress characterAtIndex:0] ) 
    {
        case 0x7F: // backspace
        case 0x0D: // return
            return theEvent;
        default:
            ViLog( @"could not find method for '%c' :: 0x%04X", [keyPress characterAtIndex:0], [keyPress characterAtIndex:0] );
            ViLog( @"%@", activeKeyMap );
            return nil;
    }
}

/**
 * Sets the mode
 */
- (void)setMode:(ViMode)theMode
{
    mode = theMode;
	[currentCursorView setMode:theMode];	
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
    if ( lastWindow != theWindow ) {
        lastWindow = theWindow;
        [command setWindow:theWindow];
        responder = [theWindow firstResponder];
		
		[currentCursorView removeFromSuperview];
		currentCursorView = [[ViView alloc] initWithFrame:[responder bounds]];
		[responder addSubview:currentCursorView];
		[currentCursorView setMode:mode];
	}
}

- (void)releaseWindow:(NSWindow*)theWindow
{
	if( lastWindow == theWindow){
		[command releaseWindow:theWindow];
		lastWindow = nil;
		responder = nil;
		[currentCursorView removeFromSuperview];
	}
}

@end
