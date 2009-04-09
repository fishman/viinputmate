/* ViCommandPanelController.h

2006, Jason Corso

This class manages the input on a "Vi Command Window" and makes Cocoa text panes behave like (some small subset) 
of Vi editing.  Note, the text panes begin in "input mode" similar to the Bash shell using vi-like editing.

This code is based on the I-Search Input Manager by Michael McCracken.

This work is licensed under the Creative Commons Attribution-ShareAlike License. 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/1.0/ 
or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
*/

#import <Cocoa/Cocoa.h>
#import <ctype.h>

#import "ViView.h"

#define __TEXTMATE__ 1


@interface ViCommandPanelController : NSWindowController {
	IBOutlet NSTextField *textField;
	NSString *cmdString;
		
	// probably don't need to keep the arrays as the members
	NSArray* singleCharKeys;
	NSArray* singleCharSels;
	NSDictionary* singleDict;
	NSArray* mode1Keys_d;
	NSArray* mode1Sels_d;
	NSDictionary* mode1Dict_d; 
	NSArray* mode1Keys_c;
	NSArray* mode1Sels_c;
	NSDictionary* mode1Dict_c; 
	NSArray* mode1Keys;
	NSArray* mode1Dicts;
	NSDictionary* mode1Dict;
	
	id firstResponder;
	
	/** the mode manages how to handle the character input
	  *  0 -- single character, normal, initial, default mode
	  *  1 -- multiple character input initiated by a d.  this will change in the future
	  *  2 -- searching mode (implementing using an integrated McCracken's incremental search (bless open source)
	  *  3 -- a number was entered first...and we'll construct the number and then process what follows
	  *  4 -- single character replacement
	  *  5 -- some support for ex style : commands like :w
	  */
	int mode;
	int locMod;
	int selLen;
	int saveCmdString;
	
	/** mode 1 variables */
	int mode1_repeat;
	
	/** searching variables  **/
	BOOL mode2_dirIsForward;
	BOOL searchIsWrapping;
	BOOL searchIsFirstTime;
	BOOL searchIsFromARepeat;
	NSRange mode2_currentRange;  // used during searching to set ranges
	NSMutableString* lastSearchString;
	
	/** mode 3 variables */
	
	/** mode 4 variables */
	
	
	/** mode 5 variables */
	
	/** cursor view **/
	NSView * currentCursorView;
	
	NSSize lastOakViewSize;
	NSSize currentOakViewSize;
	
	/** Vi command mode pasteboard **/
	NSPasteboard * mViPasteboard;

  ViMode currentMode;
}

+ (id)sharedViCommandPanelController;

- (IBAction)textFieldAction:(id)sender;

- (IBAction)handleInputAction:(id)sender;
- (IBAction)doVi:(id)sender;

/*  Utility methods that many of the others will call */
- (void)reflectAction:(NSString*)msg;
- (int)getIndexForLineNumber:(int)number ofString: (NSString*)string;
- (void)drawCursor;


/*  Methods acting on single character during command mode */
- (void)single_braceL;
- (void)single_braceR;
- (void)single_caret;
- (void)single_colon;
- (void)single_dollar;
- (void)single_digit;
- (void)single_questionmark;
- (void)single_slash;
- (void)single_underscore;
- (void)single_A;
- (void)single_a;
- (void)single_b;
- (void)single_c;
- (void)single_d;
- (void)single_e;
- (void)single_G;
- (void)single_h;
- (void)single_I;
- (void)single_i;
- (void)single_j;
- (void)single_J;
- (void)single_k;
- (void)single_l;
- (void)single_n;
- (void)single_N;
- (void)single_o;
- (void)single_O;
- (void)single_p;
- (void)single_r;
- (void)single_u;
- (void)single_w;
- (void)single_x;


/* Methods for multiple character input */
- (void)handleMode1;
- (void)mode1_cw;
- (void)mode1_dd;
- (void)mode1_dw;
- (void)mode1_dl;
- (void)mode1_dh;
- (void)mode1_dk;


/* Methods for mode 2 -- SEARCHING */
- (void)handleSearch:(NSString*)searchString;


/* Methods for mode 3 -- Building a number and then doing a command */
- (void)handleMode3;


/* Methods for mode 4 -- single character replacement */
- (void)handleMode4;

/* Methods for mode 5 -- some support for : commands from ex */
- (void)handleMode5;

/* TextMate lacks setSelectedRange */
- (void)setSelectedRange:(NSRange)cRange withResponder:(id)responder;


- (void)setMode:(ViMode)theMode;
- (ViMode)getMode;

- (void)keyDown:(NSEvent *)theEvent;

@end
