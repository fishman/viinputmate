#import "ViCommandPanelController.h"

@implementation ViCommandPanelController

+ (id)sharedViCommandPanelController {
  static ViCommandPanelController *sharedInstance = nil;
  if (!sharedInstance) {
    sharedInstance = [[ViCommandPanelController alloc] init];
  }
  return sharedInstance;
}

- (id)init {
	self = [super initWithWindowNibName:@"ViCommandPanel" owner:self];
	if (self) {
		lastOakViewSize.width = 0;
		lastOakViewSize.height = 0;
		
		[self setWindowFrameAutosaveName:@"ViCommandPanel"];

		// ADDED by Jerome Duquennoy (2 Feb 07) ---------------------------
		[[self window] setDelegate:self];
		[[self window] setHasShadow:NO];
		//----------------------------------

		singleCharKeys = [NSArray arrayWithObjects:
							 @"{",
							 @"}",
							 @"^",
							 @":",
							 @"?",
							 @"/",
							 @"0",
							 @"1",
							 @"2",
							 @"3",
							 @"4",
							 @"5",
							 @"6",
							 @"7",
							 @"8",
							 @"9",
							 @"A",
							 @"c",
							 @"e",
							 @"E",
							 @"G",
							 @"I",
               @"l",
							 @"n",
							 @"N",
							 @"h",
							 @"j",
							 @"J",
							 @"k",
							 @"r",
							 @"$",
							 @"_",
							 @"x",
							 @"w",
							 @"W",
							 @"b",
							 @"B",
							 @"u",
							 @"o",
							 @"O",
							 @"i",
							 @"a",
							 @"d",
							 @"p",
               @" ",
               @">",
               @"<",
							 NULL];
		singleCharSels = [NSArray arrayWithObjects:
		                     @"single_braceL",
							 @"single_braceR",
							 @"single_caret",
							 @"single_colon",
							 @"single_questionmark",
							 @"single_slash",
							 @"single_underscore",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_digit",
							 @"single_A",
							 @"single_c",
		                     @"single_e",
							 @"single_E",
							 @"single_G",
                             @"single_I",
							 @"single_l",
							 @"single_n",
							 @"single_N",
							 @"single_h",
							 @"single_j",
							 @"single_J",
							 @"single_k",
							 @"single_r",
							 @"single_dollar",
							 @"single_underscore",
							 @"single_x",
							 @"single_w",
							 @"single_w",
							 @"single_b",
							 @"single_B",
							 @"single_u",
							 @"single_o",
							 @"single_O",
							 @"single_i",
							 @"single_a",
							 @"single_d",
							 @"single_p",
               @"single_space",
               @"single_gt",
               @"single_lt",
							 NULL];
		singleDict = [NSDictionary dictionaryWithObjects:singleCharSels forKeys:singleCharKeys];
		[singleDict retain];  // i am pretty sure that we only need to retain the dictionary
		                      // But, my understanding of ObjC is very poor, so I could be wrong here.
							  
		// we also create multiple dictionaries for the two-key mode1 input
		mode1Keys_d = [NSArray arrayWithObjects:
		                     @"d",
							 @"h",
							 @"j",
							 @"k",
							 @"l",
							 @"w",
							 @"$",
							 NULL];
		mode1Sels_d = [NSArray arrayWithObjects:
							 @"mode1_dd",
							 @"mode1_dh",
							 @"mode1_dj",
							 @"mode1_dk",
							 @"mode1_dl",
							 @"mode1_dw",
							 @"mode1_ddollar",
							 NULL];
							 
		mode1Dict_d = [NSDictionary dictionaryWithObjects:mode1Sels_d forKeys:mode1Keys_d];
		[mode1Dict_d retain];
		
		mode1Keys_c = [NSArray arrayWithObjects:
							 @"w",
							 NULL];
		mode1Sels_c = [NSArray arrayWithObjects:
							 @"mode1_cw",
							 NULL];
							 
		mode1Dict_c = [NSDictionary dictionaryWithObjects:mode1Sels_c forKeys:mode1Keys_c];
		[mode1Dict_c retain];
		
		
		// these marshal out the second dictionary from the first key
		mode1Keys = [NSArray arrayWithObjects:
			                 @"d",
							 @"c",
							 NULL];
		mode1Dicts = [NSArray arrayWithObjects:
		                     mode1Dict_d,
							 mode1Dict_c,
							 NULL];
		mode1Dict = [NSDictionary dictionaryWithObjects:mode1Dicts forKeys:mode1Keys];
		[mode1Dict retain];
		
		
		lastSearchString = [NSMutableString stringWithCapacity:16];
		[lastSearchString retain];
		
    // TextMate additions
		mViPasteboard = [NSPasteboard	pasteboardWithName:@"ViPasteboard"];

    currentMode = ViInsertMode;
		
		[textField setDelegate:self];
	}
	return self;
}

- (void)dealloc {
  [super dealloc];
  [singleDict release];
	[mViPasteboard release];
}


- (void)windowDidLoad {
  [[self window] setTitle:NSLocalizedString(@"Vi Command", @"")];
  [super windowDidLoad];
}

- (void)showWindowIfNeeded:(id)sender;
{
  NSWindow *searchWindow = [self window];
  if(![searchWindow isVisible]) {

    // CHANGED  by Jerome Duquennoy (2 Feb 07) and Jason Corso (to change location on nonscrollview) ---------
#ifdef __TEXTMATE__
		NSView *view = [[sender firstResponder] enclosingScrollView];
    if (view == nil) view = [sender firstResponder];		


		id responder = [sender firstResponder];
		
		NSRect bounds = [responder bounds];
		
		currentOakViewSize = NSMakeSize(bounds.size.width, bounds.size.height);
		
		if (lastOakViewSize.width == 0 )
		{
			lastOakViewSize = NSMakeSize(currentOakViewSize.width, currentOakViewSize.height);
		}
		// NSLog(@"Creating subview");
		if (currentCursorView == nil)
			currentCursorView = [[ViView alloc] initWithFrame:bounds];
		
		
		if (!NSEqualSizes(currentOakViewSize, lastOakViewSize))
		{
			[currentCursorView setFrame:bounds];
		}
				
		[responder addSubview:currentCursorView];
		
		[self setMode:ViCommandMode];
		
#else
		NSView *view = [sender enclosingScrollView];
    if (view == nil) view = sender;
#endif
    NSWindow *textFieldWindow = [view window];
    NSRect textFieldRect;
    NSPoint textFieldBottomLeft;
    NSRect  searchWindowFrame = [searchWindow frame];

    if ([view isKindOfClass:[NSScrollView class]])
    {
      textFieldRect = [view convertRect: [[(NSScrollView*)view contentView] frame] toView: nil];
      textFieldBottomLeft = NSMakePoint(textFieldRect.origin.x,
          textFieldRect.origin.y);
      searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldBottomLeft];
    }
    else
    {
      textFieldRect = [view convertRect: [view bounds] toView: nil];
      searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldRect.origin];
      searchWindowFrame.origin.y -= searchWindowFrame.size.height;
    }

    searchWindowFrame.size.width = textFieldRect.size.width;

    [searchWindow setFrame:searchWindowFrame display:YES];
    //---------------------------------
  }
  [self showWindow:self];
  mode = 0;  // user hit the trigger key again...
}



- (IBAction)handleInputAction:(id)sender{
	[self showWindowIfNeeded: sender];
	[self doVi: sender];
}


- (IBAction)doVi:(id)sender {
	id targetWindow = [NSApp mainWindow];
    firstResponder = [targetWindow firstResponder];
	
  // TEXTMATE:
		if ([firstResponder isKindOfClass:[NSTextView class]] || 
				[firstResponder isKindOfClass:[NSClassFromString(@"OakTextView") class]] ) {
		cmdString = [textField stringValue];
		
		if ([cmdString length] < 1) {
			mode = 0;
			return;
		}
		
		locMod = 0;
		selLen = 1;
		saveCmdString = 0;
		
		// first, we check need to check the mode.  if it is a new entry (which will be most of the time)
		//  then we just create a single element substring corresponding to the key and find out what to do
		switch (mode)
		{
		case 0:
		{
			NSString* firstKey = [cmdString substringToIndex:1];
		
			NSString* selNSString = [singleDict objectForKey:firstKey];
		
			if (selNSString != nil)
			{
				SEL theSel = sel_getUid([selNSString UTF8String]);
			
				if (theSel != nil)
					[self performSelector:theSel];
			}
		
			if (!saveCmdString)
				[textField setStringValue:@""];
			
			NSRange cRange = [firstResponder selectedRange];
		
			cRange.location += locMod;
			if (cRange.location < 0)
				cRange.location = 0;
			cRange.length = selLen;

#ifdef __TEXTMATE__	
      [self setSelectedRange:cRange withResponder:firstResponder];
#else
			[firstResponder setSelectedRange:cRange];
			[firstResponder scrollRangeToVisible:cRange];
#endif
		}
		break;
		// the d key was pressed first
		case 1:
		{
			[self handleMode1];
			
			if (!saveCmdString)
				[textField setStringValue:@""];
		}
		break;
		//  a search is in progress
		case 2:
		{
			saveCmdString=1;
			[self handleSearch:[cmdString substringFromIndex:1]];
			if (!saveCmdString)
				[textField setStringValue:@""];
		}
		break;
		// a number is being entered (only supported currently by ##G)
		case 3:
		{
			[self handleMode3];
			if (!saveCmdString)
				[textField setStringValue:@""];
		}
		break;
		// single character replacement mode
		case 4:
		{
			[self handleMode4];
			if (!saveCmdString)
				[textField setStringValue:@""];
		}
		break;
		case 5:
		{
			// For mode 5, nothing must be done except.  We are always building the command string.
			//  The return key handler will actually issue the "handle" command 
		}
		break;
		}
	}
}

// user hits enter in popup command window's text field.
- (void)textFieldAction:(id)sender {
	// function depends on mode
	switch (mode)
	{
		case 2:
		if (searchIsFromARepeat)
		{
			NSString* newCmdString;
			if (mode2_dirIsForward)
				newCmdString = [@"/" stringByAppendingString:lastSearchString];
			else
				newCmdString = [@"?" stringByAppendingString:lastSearchString];
			
			[textField setStringValue:newCmdString];

			[self doVi:self];
		}
		// when Vi terminates a search, it does not enter input mode...
		mode = 0;
		break;
		
		
		case 5:
			[self handleMode5];
			mode = 0;
		break;
		
		
		default:
			mode = 0;
		break;
	}
	
	// it appears we always want to do becuase the focus switches off to the desktop otherwise
	[[self window] makeFirstResponder: textField];
	// we always want to set the string value to zippo on enter...
	[textField setStringValue:@""];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self doVi:self];
}


/** This is some testing code where I manually draw the cursor position as a frame rectangle
 * instead of relying on the selected range to draw the cursor position.  I'm not sure if it's
 * worth the extra overhead to do this type of rendering for the user.
 *
 *  I am not sure if this is the best way to represent the cursor since it requires manual drawing
 *  on the NSTextView and the rendered cursor does not blink as we are used to....
 *  The bigger issue is that I would need to erase the cursor I drew last time.  Currently the only way that I know
 *  how to do that would be to have the whole NSTextView redraw;  which is clearly a waste of computation.
*/
- (void)drawCursor {
	NSRange cR = [firstResponder selectedRange];
	//NSLog([NSString stringWithFormat:@"selection is %i,%i",cR.location,cR.length]);
	cR.length=1;
	unsigned pRectNo;
	NSRectArray rects = [[firstResponder layoutManager]
										rectArrayForCharacterRange:cR
									  withinSelectedCharacterRange:cR
									               inTextContainer:[firstResponder textContainer]
										                 rectCount:&pRectNo];
	
	//NSLog([NSString stringWithFormat:@"got %i rects",pRectNo]);
	NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
	[theContext saveGraphicsState];
	
	NSRect frameRect = [firstResponder frame];
	[[NSColor orangeColor] setFill];
	int i;
	for (i=0;i<pRectNo;i++)
	{
	//	NSLog([NSString stringWithFormat:@"rect %i is %f,%f %f,%f",i,rects[i].origin.x,rects[i].origin.y,
	//	                                            rects[i].size.width,rects[i].size.height]);
		rects[i].origin.y = frameRect.size.height-rects[i].origin.y-rects[i].size.height;
		NSFrameRectWithWidth(rects[i],1);
		[firstResponder setNeedsDisplayInRect:rects[i] avoidAdditionalLayout:YES];
	}
	[theContext restoreGraphicsState];
}


- (void)reflectAction:(NSString*)msg {
	[[self window] setTitle:msg];
}


- (int)getIndexForLineNumber:(int)number ofString: (NSString*)string 
{
	unsigned numberOfLines, index, stringLength = [string length];
	
	if (number == 1)
		return 0;

	for (index = 0, numberOfLines = 1; (index < stringLength) && (numberOfLines < number); numberOfLines++)
	{	
		index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
	}
			
	return index;
}



///  Beginning Single Item Definitions


- (void)single_braceL {
	[self reflectAction:@"Vi: ({) Beginning of Prev Paragraph"];
	// we have to move left until we hit the paragraph before we can issue the move call
	int loc = [firstResponder selectedRange].location;
	NSString* theText = [[firstResponder textStorage] string];
	do 
	{
		loc--;
		if (loc < 0)
		{ 
			loc=0;
			break;
		}
	} while (isspace([theText characterAtIndex:loc]));
	
	NSRange nR = NSMakeRange(loc,1);
	[firstResponder setSelectedRange:nR];
	[firstResponder moveToBeginningOfParagraph:self];
}

- (void)single_braceR {
	[self reflectAction:@"Vi: (}) Beginning of Next Paragraph"];
	[firstResponder performSelector:@selector(moveRight:) withObject:[NSApp mainWindow]];
	[firstResponder performSelector:@selector(moveToEndOfParagraph:) withObject:[NSApp mainWindow]];
	[firstResponder performSelector:@selector(moveRight:) withObject:[NSApp mainWindow]];
}


- (void)single_caret {
	[self reflectAction:@"Vi: (^) First non-Blank Character"];
	[firstResponder moveToBeginningOfLine:self];
	// now, move to the right until we hit a character
	int loc = [firstResponder selectedRange].location;
	NSString* theText = [[firstResponder textStorage] string];
	while (isspace([theText characterAtIndex:loc]))
	{
		loc++;
		if (loc >= [theText length])
		{ 
			loc=[theText length]-1;
			break;
		}
	} 
	NSRange nR = NSMakeRange(loc,1);
	[firstResponder setSelectedRange:nR];
}


/** enter into ex-style command buffer mode */
- (void)single_colon {
	[self reflectAction:@"Vi: (:) Ex command mode "];
	mode = 5;
	saveCmdString = 1;
}


- (void)single_digit {
	[self reflectAction:@"Vi: (#) Build number "];
	mode = 3;
	saveCmdString = 1;
}


- (void)single_dollar {
	[self reflectAction:@"Vi: ($) End Of Line"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveToEndOfLine:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveToEndOfLine:self];
#endif
	locMod = -1;
}


//  this is kick of the forward searching capability
- (void)single_questionmark {
	[self reflectAction:@"Vi: (?) Reverse Search"];
	mode = 2;
	mode2_dirIsForward = NO;
	searchIsFirstTime = YES;
	saveCmdString=1;
	searchIsFromARepeat = NO;
	// we need to indicate if there was a past search to repeat (in the dark)
	if (![lastSearchString isEqualToString:@""]) {
		searchIsFromARepeat = YES;
	}
	else // only set the searchwrapping off if its new, else just keep its value
		searchIsWrapping = NO;
}

//  this is kick of the forward searching capability
- (void)single_slash {
	[self reflectAction:@"Vi: (/) Forward Search"];
	mode = 2;
	mode2_dirIsForward = YES;
	searchIsFirstTime = YES;
	saveCmdString=1;
	searchIsFromARepeat = NO;
	// we need to indicate if there was a past search to repeat (in the dark)
	if (![lastSearchString isEqualToString:@""]) {
		searchIsFromARepeat = YES;
	} 
	else // only set the searchwrapping off if its new, else just keep its value
		searchIsWrapping = NO;
}

- (void)single_underscore {
	[self reflectAction:@"Vi: (_) Beginning Of Line"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveToBeginningOfLine:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveToBeginningOfLine:self];
#endif
}

// Insert at the end of the current line.  
// Question: Should we handle this compatible Vi mode...or consider wrapped lines, wrapped
- (void)single_A {
	[self reflectAction:@"Vi: (A) Insert at end of line"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveToEndOfLine:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveToEndOfLine:self];
#endif
  [[self window] orderOut:self];
	selLen = 0;
}

- (void)single_a {
	[self reflectAction:@"Vi: (a) Insert Right"];
#ifdef __TEXTMATE__
  [firstResponder performSelector: @selector(moveRight:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveRight:self];
#endif
	[[self window] orderOut:self];
	selLen = 0;
}

- (void)single_b {
	[self reflectAction:@"Vi: (b) Move Word Left"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveWordBackward:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveWordLeft:self];
#endif
}


- (void)single_c {
	[self reflectAction:@"Vi: (c) Change Word --multi-- "];
	mode = 1;
	saveCmdString = 1;
}

- (void)single_d {
	[self reflectAction:@"Vi: (d) Delete --multi-- "];
	mode = 1;
	saveCmdString = 1;
}

- (void)single_e {
	[self reflectAction:@"Vi: (e) Move To End Of Word"];
	
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveWordForward:) withObject: [NSApp mainWindow]];
#else
	// CTS has not end of word motion
	// We will move to the Word on the right, and then roll backwards
	
	NSRange curRange = [firstResponder selectedRange];
	NSTextStorage* curTextStorage = [firstResponder textStorage];
	
	// if we are at the end of the buffer, just return
	if (curRange.location + 1 >= [curTextStorage length])
		return;
		
	NSString* theText = [curTextStorage string];
	
	[firstResponder moveWordRight:self];
	[firstResponder moveRight:self];  // cocoa just moves to the space end of the current word
										  //  but vi moves to the beginning of the next word...
	
	// begin the rolling backwords
	// basically, continue to move backwords until it's an alpha or a number
	curRange = [firstResponder selectedRange];
	int loc = curRange.location - 1;
	do 
	{
		loc--;
	} while (!(isalpha([theText characterAtIndex:loc]) || isalpha([theText characterAtIndex:loc]) ));
	locMod = loc - curRange.location;
#endif
}


- (void)single_G {
	[self reflectAction:@"Vi: (G) Move to last line"];
	[firstResponder performSelector: @selector(moveToEndOfDocument:) withObject:[NSApp mainWindow]];
	[firstResponder performSelector: @selector(moveToBeginningOfLine:) withObject:[NSApp mainWindow]];
}


- (void)single_h {
	[self reflectAction:@"Vi: (h) Left"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveLeft:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveLeft:self];
#endif
	locMod = -1;
}

- (void)single_I {
	[self reflectAction:@"Vi: (I) Insert at Beginning of Line"];
#ifdef __TEXTMATE__
  [firstResponder performSelector: @selector(moveToBeginningOfLine:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveToBeginningOfLine:self];
#endif
	[[self window] orderOut:self];
	selLen = 0;
}

- (void)single_i {
	[self reflectAction:@"Vi: (i) Insert"];
	[[self window] orderOut:self];
	selLen = 0;
}

- (void)single_j {
	[self reflectAction:@"Vi: (j) Down"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveDown:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveDown:self];
#endif
}


- (void)single_J {
	[self reflectAction:@"Vi: (J) Join next line with current"];
  // TEXTMATE:
#if 0

  // findWithOptions
  {
    action = findNext; 
    findInProjectIgnoreCase = 0; 
    findInProjectRegularExpression = 0; 
    findString = "$\\n\\s*"; 
    ignoreCase = 0; 
    regularExpression = 1; 
    replaceAllScope = document; 
    replaceString = key; 
    wrapAround = 0; 
  }
  // deleteForward
#endif
  NSDictionary *dict;

  dict = [NSDictionary dictionaryWithObjectsAndKeys:
               @"findNext", @"action", 
               [NSNumber numberWithBool:FALSE], @"findInProjectIgnoreCase", 
               [NSNumber numberWithBool:FALSE], @"findInProjectRegularExpression", 
               @"$\\n\\s*",@"findString", 
               [NSNumber numberWithBool:FALSE], @"ignoreCase", 
               [NSNumber numberWithBool:TRUE], @"regularExpression", 
               @"document", @"replaceAllScope", 
               @"key", @"replaceString", 
               [NSNumber numberWithBool:FALSE], @"wrapAround", nil];
  [firstResponder findWithOptions:dict];
  [firstResponder deleteForward:nil];
}


- (void)single_k {
	[self reflectAction:@"Vi: (k) Up"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveUp:) withObject:[NSApp mainWindow]];
	//move_up((text::view*)firstResponder);
#else
	[firstResponder moveUp:self];
#endif
}

- (void)single_l {
	[self reflectAction:@"Vi: (l) Right"];
#ifdef __TEXTMATE__
	[firstResponder performSelector: @selector(moveRight:) withObject:[NSApp mainWindow]];
#else
	[firstResponder moveRight:self];	
#endif
}


// repeat the last search in the same direction
- (void)single_n {
	searchIsFirstTime = NO;
	searchIsFromARepeat = NO;
	[self handleSearch:lastSearchString];
	mode = 0;
}


// repeat the last search in the opposite direction
- (void)single_N {
	BOOL dirStack = mode2_dirIsForward;
	if (mode2_dirIsForward == YES)
		mode2_dirIsForward = NO;
	else
		mode2_dirIsForward = YES;
	
	searchIsFirstTime = NO;
	[self handleSearch:lastSearchString];
	mode = 0;
	
	mode2_dirIsForward = dirStack;
}


- (void)single_o {
	[self reflectAction:@"Vi: (o) Insert At New Line"];
#ifdef __TEXTMATE__
  [firstResponder performSelector: @selector(moveToEndOfParagraph:) withObject: [NSApp mainWindow]];
//  [firstResponder insertText:@"\n"];
	[firstResponder performSelector: @selector(insertNewline:) withObject: [NSApp mainWindow]];
	[firstResponder performSelector: @selector(indent:) withObject:[NSApp mainWindow]];
	[[self window] orderOut:self];
	selLen = 0;
#else
	[firstResponder moveToEndOfLine:self];
	[firstResponder insertNewlineIgnoringFieldEditor:self];
	// wrapping causes some problem here.  We now have to check if there is an
	//  alpha character underneath the cursor (in the case of wrapping).  And
	//  and if there is, we need to insert a second newline character
	NSRange cRange = [firstResponder selectedRange];
	NSString* theText = [[firstResponder textStorage] string];
	if (!isspace([theText characterAtIndex:cRange.location]))
	{
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
	}
	[[self window] orderOut:self];
	selLen = 0;
#endif
}


- (void)single_O {
	[self reflectAction:@"Vi: (O) Insert New Line Above"];
#ifdef __TEXTMATE__
  [firstResponder performSelector: @selector(moveToBeginningOfLine:) withObject: [NSApp mainWindow]];
//  [firstResponder insertText:@"\n"];
	[firstResponder performSelector: @selector(insertNewline:) withObject: [NSApp mainWindow]];

  [firstResponder performSelector: @selector(moveUp:) withObject: [NSApp mainWindow]];

	[[self window] orderOut:self];
	selLen = 0;
#else
	NSRange cR = [firstResponder selectedRange];
	[firstResponder moveUp:self];
	NSRange nR = [firstResponder selectedRange];
	if (cR.location == nR.location)
	{
		[firstResponder moveToBeginningOfLine:self];
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
		[[self window] orderOut:self];
		selLen = 0;	
		return;
	}
	
	[firstResponder moveToEndOfLine:self];
	[firstResponder insertNewlineIgnoringFieldEditor:self];
	// wrapping causes some problem here.  We now have to check if there is an
	//  alpha character underneath the cursor (in the case of wrapping).  And
	//  and if there is, we need to insert a second newline character
	NSRange cRange = [firstResponder selectedRange];
	NSString* theText = [[firstResponder textStorage] string];
	if (!isspace([theText characterAtIndex:cRange.location]))
	{
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
	}
	[[self window] orderOut:self];
	selLen = 0;
#endif
}



// Put the kill buffer back into the text.  
// Changed in 0.2 to set the selection range to 0 because it was replacing the currently selected
//  character (I currently render the moving cursor as a selection in the NSTextField).
// This does not fix it.  ???  I may have to manage my own delete buffers....
- (void)single_p {
	[self reflectAction:@"Vi: (p) Put Kill Buffer Back "];
#ifdef __TEXTMATE__
  [firstResponder readSelectionFromPasteboard:mViPasteboard];
	[firstResponder performSelector: @selector(moveRight:) withObject:[NSApp mainWindow]];
	[firstResponder performSelector: @selector(moveLeft:) withObject:[NSApp mainWindow]];

#else
	// Wrapped text causes problems here.  Need to figure a good way to handle wrapped text.
	// Perhaps the solution is to add newlines in the beginning and end of a deleted line of text
    [firstResponder moveDown:self];
	NSRange cR = [firstResponder selectedRange];
	cR.length = 0;
	[firstResponder setSelectedRange:cR];
	[firstResponder yank:self];
#endif
}



/* start a single character replacement...mode 4 */
- (void)single_r {	
	[self reflectAction:@"Vi: (r) Single character replacement "];
	mode = 4;
	saveCmdString = 1;
}



- (void)single_u {
	[self reflectAction:@"Vi: (u) Undo"];
#ifdef __TEXTMATE__	
	[firstResponder undo:nil];
#else
	NSUndoManager* undoMgr = [firstResponder undoManager];
	[undoMgr undo];
#endif
}

- (void)single_w {
	[self reflectAction:@"Vi: (w) Move Word Right"];

#ifdef __TEXTMATE__
  id window = [NSApp mainWindow];

  [firstResponder performSelector: @selector(moveWordForward:) withObject: window];
  [firstResponder performSelector: @selector(moveWordForward:) withObject: window];
  [firstResponder performSelector: @selector(moveWordBackward:) withObject: window];
#else
	NSRange curRange = [firstResponder selectedRange];
	NSTextStorage* curTextStorage = [firstResponder textStorage];
	
	
	// if we are at the end of the buffer, just return
	if (curRange.location + 1 >= [curTextStorage length])
		return;
	
	// it appears that the cocoa text system fails to move forward if the word is a 
	//  single character;  like a.  So, let's go and check if this is the case.
	if (isspace([[curTextStorage string] characterAtIndex:(curRange.location+1)]))
	{
		[firstResponder moveRight:self];
		NSString* theText = [curTextStorage string];
		// continue moving right while we are still space
		int loc = curRange.location+1;
		while (isspace([theText characterAtIndex:loc]))
		{
			[firstResponder moveRight:self];
			loc++;
			if (loc >= [curTextStorage length])
				return;
		}
	} 
	else
	{
	    [firstResponder moveWordRight:self];
		[firstResponder moveRight:self];  // cocoa just moves to the end of the current word
										//  but vi moves to the beginning of the next word...
	}
#endif
}

- (void)single_x {
	[self reflectAction:@"Vi: (x) Delete Character"];
	//[firstResponder deleteForward:self];
  // TEXTMATE:
	[firstResponder performSelector: @selector(deleteForward:) withObject:[NSApp mainWindow]];
	
}


- (void)single_space {
	[self reflectAction:@"Vi: ( ) Toggle Folding"];
	//[firstResponder deleteForward:self];
  // TEXTMATE:
	[firstResponder performSelector: @selector(toggleFolding:) withObject:[NSApp mainWindow]];

}


- (void)single_lt {
	[self reflectAction:@"Vi: (<) Shift Left"];
	//[firstResponder deleteForward:self];
  // TEXTMATE:
	[firstResponder performSelector: @selector(shiftLeft:) withObject:[NSApp mainWindow]];
}

- (void)single_gt {
	[self reflectAction:@"Vi: (>) Shift Right"];
	//[firstResponder deleteForward:self];
  // TEXTMATE:
	[firstResponder performSelector: @selector(shiftRight:) withObject:[NSApp mainWindow]];
}

- (void)single_s 
{
	[self reflectAction:@"Vi: (s) Substitute Character"];
	
	[firstResponder performSelector: @selector(deleteForward:) withObject:[NSApp mainWindow]];
	
}

- (void)handleMode1 {

	int len = [cmdString length];
	
	// first thing is a sanity check
	//  the cmdString should be 2 or more characters long
	if (len < 2)
	{
		// try to gracefully recover
		[textField setStringValue:@""];
		mode = 0;
		return;
	}
	
	// second thing to do is to see if the last character of the cmdString is a number
	//  if it is a number, then we just drop out and let the user continue typing
	unichar c = [cmdString characterAtIndex:(len-1)];
	if (isdigit(c)) 
	{
	  saveCmdString=1;
	  return;
	}
	
	NSString* firstKey = [cmdString substringToIndex:1];
	NSString* lastKey = [cmdString substringFromIndex:(len-1)];
	mode1_repeat = 1;
	if (len > 2)
	{
	  NSRange numRange = NSMakeRange(1,len-2);
	  NSString* numStr = [cmdString substringWithRange:numRange];
	  mode1_repeat = [numStr intValue];
	}
	
	// now we have to get the function to actually call!
	NSDictionary* secondDict = [mode1Dict objectForKey:firstKey];
	
	if (secondDict != nil)
	{
		NSString* selNSString = [secondDict objectForKey:lastKey];
		if (selNSString != nil)
		{
			SEL theSel = sel_getUid([selNSString UTF8String]);
			
			if (theSel != nil) 
			{
				[self performSelector:theSel];
				
				// only do these if we actually did some operation
				NSRange cRange = [firstResponder selectedRange];
				
				cRange.location += locMod;
				if (cRange.location < 0)
					cRange.location = 0;
				cRange.length = selLen;
				
#ifdef __TEXTMATE__	
        [self setSelectedRange:cRange withResponder:firstResponder];
#else
        [firstResponder setSelectedRange:cRange];
        [firstResponder scrollRangeToVisible:cRange];
#endif
			}
		}
	}
	
	// clean up is the same for any of the fall-outs too
	mode = 0;
}


/** change one or more words forward.  A bug was fixed in 0.2 that made sure to erase the whole word */
- (void)mode1_cw {
	[self reflectAction:[@"Vi: (cw) Change Word " stringByAppendingString:[NSString stringWithFormat:@"%i", mode1_repeat]]];
	int i;
	[firstResponder performSelector: @selector(moveRight:) withObject:[NSApp mainWindow]];
	[firstResponder performSelector: @selector(moveLeft:) withObject:[NSApp mainWindow]];
	
	for (i=0;i<mode1_repeat;i++)
		[firstResponder performSelector: @selector(deleteWordForward:) withObject:[NSApp mainWindow]];
	[[self window] orderOut:self];
	selLen = 0;
}


/** delete one or more lines forward(down).  Fixed a bug in 0.2 -- changed it to use a mark because there
 *  was unexpected behavior using the deleteToEndOfLine method
 */
- (void)mode1_dd {
	[self reflectAction:@"Vi: (dd) Delete Lines "];
	int i;
	
#ifdef __TEXTMATE__
	id window = [NSApp mainWindow];


  [firstResponder performSelector: @selector(selectLine:) withObject: window];
  for (i=1;i<mode1_repeat;i++)
  {
    [firstResponder performSelector: @selector(moveDownAndModifySelection:) withObject: window];
  }
  [firstResponder writeSelectionToPasteboard:mViPasteboard 
                                   types:[NSArray arrayWithObject:@"NSStringPboardType"] ];

  [firstResponder performSelector: @selector(deleteBackward:) withObject: window];
#else
  [firstResponder moveToBeginningOfLine:self];
	// if user tries to delete more lines below the end of the doc...will actually delete up in this code...
	int numLinesMovedDown=0;	
	for (i=0;i<mode1_repeat;i++)
	{
		NSRange cP = [firstResponder selectedRange];
		[firstResponder moveDown:self];
		NSRange nP = [firstResponder selectedRange];
		if (cP.location == nP.location)
			break;
		numLinesMovedDown++;
	}
	[firstResponder setMark:self];
	for (i=0;i<numLinesMovedDown;i++)
	{
		[firstResponder moveUp:self];
	}
	[firstResponder deleteToMark:self];
#endif
}


/* Are there adv/disadv to deleting parts of the text through the setMark/DeleteToMark versu
 *  manually constructing the range and then deleteCharactersInRange?
 */
- (void)mode1_dh {
	[self reflectAction:@"Vi: (dh) Delete multiple characters to the left"];
#ifdef __TEXTMATE__
  int i;

  id window = [NSApp mainWindow];
  for(  i = 0; i < mode1_repeat; i++)
  {
    [firstResponder performSelector: @selector(moveBackwardAndModifySelection:) withObject: window];
  }
  [firstResponder performSelector: @selector(deleteBackward:) withObject: window];
#else
	[firstResponder moveLeft:self];
	[firstResponder setMark:self];
	int i;
	for (i=0;i<mode1_repeat;i++)
		[firstResponder moveLeft:self];
	[firstResponder deleteToMark:self];
#endif
}


/* differs from dd in that it deletes from the current character location */
- (void)mode1_dj {
	[self reflectAction:@"Vi: (dj) Delete lines down "];
	int i;
	
#ifdef __TEXTMATE__
	id window = [NSApp mainWindow];

	// Clear Selection
	[firstResponder performSelector: @selector(moveRight:) withObject: window];
	[firstResponder performSelector: @selector(moveLeft:) withObject: window];
	
  [firstResponder performSelector: @selector(selectLine:) withObject: window];
  //[firstResponder writeSelectionToPasteboard:pasteboard types:types];
  for (i=0;i<mode1_repeat;i++)
  {
    [firstResponder performSelector: @selector(moveDownAndModifySelection:) withObject: window];
  }
  [firstResponder performSelector: @selector(deleteBackward:) withObject: window];
#else
	// if user tries to delete more lines below the end of the doc...will actually delete up in this code...
	int numLinesMovedDown=0;	
	for (i=0;i<mode1_repeat;i++)
	{
		NSRange cP = [firstResponder selectedRange];
		[firstResponder moveDown:self];
		NSRange nP = [firstResponder selectedRange];
		if (cP.location == nP.location)
			break;
		numLinesMovedDown++;
	}
	[firstResponder setMark:self];
	for (i=0;i<numLinesMovedDown;i++)
	{
		[firstResponder moveUp:self];
	}
	[firstResponder deleteToMark:self];
#endif
}


- (void)mode1_dk {
	[self reflectAction:@"Vi: (dk) Delete multiple lines up"];
	int i;
#ifdef __TEXTMATE__
  id window = [NSApp mainWindow];
  //[firstResponder writeSelectionToPasteboard:pasteboard types:types];
  [firstResponder performSelector: @selector(selectLine:) withObject: window];
  for (i=0;i<mode1_repeat;i++)
  {
    [firstResponder performSelector: @selector(moveUpAndModifySelection:) withObject: window];
  }
  [firstResponder performSelector: @selector(deleteBackward:) withObject: window];
#else
	[firstResponder moveLeft:self];
	[firstResponder setMark:self];
	for (i=0;i<mode1_repeat;i++)
	{
		[firstResponder moveUp:self];
	}
	[firstResponder deleteToMark:self];
#endif
}


- (void)mode1_dl {
	[self reflectAction:@"Vi: (dl) Delete multiple characters to the right"];
#ifdef __TEXTMATE__
  int i;

  id window = [NSApp mainWindow];
  for(  i = 0; i < mode1_repeat; i++)
  {
    [firstResponder performSelector: @selector(moveForwardAndModifySelection:) withObject: window];
  }
  [firstResponder performSelector: @selector(deleteForward:) withObject: window];
#else
	NSRange cR = [firstResponder selectedRange];
	cR.length = mode1_repeat;
	NSMutableString* mutstr = [[firstResponder textStorage] mutableString];
	[mutstr deleteCharactersInRange:cR];
	cR.length = 1;
	[firstResponder setSelectedRange:cR];
#endif
}

- (void)mode1_ddollar {
	[self reflectAction:@"Vi: (d$) Delete to end of current line"];
	
#ifdef __TEXTMATE__
  NSDictionary *dict;

  dict = [NSDictionary dictionaryWithObjectsAndKeys:
               @"findNext", @"action", 
               [NSNumber numberWithBool:FALSE], @"findInProjectIgnoreCase", 
               [NSNumber numberWithBool:FALSE], @"findInProjectRegularExpression", 
               @".*\\n",@"findString", 
               [NSNumber numberWithBool:FALSE], @"ignoreCase", 
               [NSNumber numberWithBool:TRUE], @"regularExpression", 
               @"document", @"replaceAllScope", 
               @"key", @"replaceString", 
               [NSNumber numberWithBool:FALSE], @"wrapAround", nil];
  [firstResponder findWithOptions:dict];
  [firstResponder insertText:@"\n"];
//	[firstResponder performSelector: @selector(insertNewline:) withObject: [NSApp mainWindow]];	
	[firstResponder performSelector: @selector(moveLeft:) withObject:[NSApp mainWindow]];
	//[firstResponder performSelector: @selector(deleteToEndOfLine:) withObject:[NSApp mainWindow]];

#else
	NSRange cR = [firstResponder selectedRange];
    cR.length = 0;
	[firstResponder setSelectedRange:cR];
	[firstResponder deleteToEndOfLine:self];
	cR.length = 1;
	cR.location = (cR.location == 0) ? 0 : cR.location - 1 ;
	[firstResponder setSelectedRange:cR];
#endif
}


/** delete one or more words forward.  
    A bug was fixed in 0.2 that made sure to erase the whole word.
	A bug was fixed in 0.3.1 to only delete extra space after words, and not other characters.
 */
- (void)mode1_dw {
	[self reflectAction:[@"Vi: (dw) Delete Word " stringByAppendingString:[NSString stringWithFormat:@"%i", mode1_repeat]]];
	int i;
#ifdef __TEXTMATE__
	for (i = 0; i<mode1_repeat; i++)
		[firstResponder performSelector:@selector(deleteWordForward:) withObject: [NSApp mainWindow]];
	
#else
	NSRange cRange = [firstResponder selectedRange];
	cRange.length = 0;
	[firstResponder setSelectedRange:cRange];
	for (i=0;i<mode1_repeat;i++)
		[firstResponder deleteWordForward:self];
	NSString* str = [[firstResponder textStorage] string];
	unichar c = [str characterAtIndex:cRange.location];
	if (isspace(c)) 
	{
		[firstResponder deleteForward:self];
	}
#endif
}



/// handle mode 2 (SEARCHING)

- (void)handleSearch:(NSString*)searchString {
	NSRange range;
	NSString *title = nil;
#ifdef __TEXTMATE__	
	[lastSearchString setString:searchString];
	int options = 0;
	
	NSMutableDictionary *dict;

  dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							 @"findNext", @"action",
               [NSNumber numberWithBool:FALSE], @"findInProjectIgnoreCase", 
               [NSNumber numberWithBool:FALSE], @"findInProjectRegularExpression", 
               searchString,@"findString", 
               [NSNumber numberWithBool:TRUE], @"ignoreCase", 
               [NSNumber numberWithBool:TRUE], @"regularExpression", 
               @"document", @"replaceAllScope", 
               @"key", @"replaceString",
							 [NSNumber numberWithBool:TRUE], @"wrapAround", nil];
  
	if(searchIsFirstTime)
	{
		[firstResponder performSelector: @selector(moveLeft:) withObject: [NSApp mainWindow]];
	}
	
	if(!mode2_dirIsForward)
	{
		[dict setObject:@"findPrevious" forKey:@"action"];
	}

/*	if ([searchString rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) 
	{
	}
	
	if(!searchIsWrapping)
	{
		[dict setObject:[NSNumber numberWithBool:FALSE] forKey:@"wrapAround"];
	}
*/
	
	[firstResponder findWithOptions:dict];

  [self setSelectedRange:range withResponder:firstResponder];
#else
	NSString *string = [firstResponder string];
	int textLen = [[firstResponder textStorage] length];
	
	// always turn this off here?
	searchIsFromARepeat = NO;
	
	[lastSearchString setString:searchString];
	int options = 0;
	
	if(!mode2_dirIsForward)
		options |= NSBackwardsSearch;
	
	if ([searchString rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
		options |= NSCaseInsensitiveSearch;
	}
	
	/* the search I am implementing right now has no "fromCmd" functionality, could be added by ctrl-/ to move ahead
	   and make it a real incremental search
	if(searchIsfromCmd && !searchIsWrapping){
		// the second successive search of the same string should start searching past the end of the first hit
		if(mode2_dirIsForward)
			currentRange.location = selectedRange.location + selectedRange.length;
		else
			currentRange.length = selectedRange.location;
	}
	*/
	NSRange selectedRange = [firstResponder selectedRange];
	
	// guarantee that we're always searching to the extent of the range we want.
	if(mode2_dirIsForward)
	{
		if (searchIsFirstTime)
			mode2_currentRange.location = [firstResponder selectedRange].location + 1;
		mode2_currentRange.length = textLen - mode2_currentRange.location; // we're always searching to the end of the view.
	}
	else
	{
		mode2_currentRange.location = 0;
		if (searchIsFirstTime)
			mode2_currentRange.length = selectedRange.location;
	}
	
	if(searchIsWrapping){
		mode2_currentRange = NSMakeRange(0,textLen);
	}
	
	
	range = [string rangeOfString:searchString
						  options:options
							range:mode2_currentRange];
	
	
	if (range.location == NSNotFound){
		if(!searchIsFirstTime) NSBeep();
		
		title = [NSString stringWithFormat:NSLocalizedString(@"Vi: Failing %@I-Search", @""), 
			(searchIsWrapping ? NSLocalizedString(@"wrapped ", @"") : @"")];
		
		if(!mode2_dirIsForward) title = [title stringByAppendingString:NSLocalizedString(@" backward",@"")];
		
		searchIsWrapping = YES;
		[[self window] setTitle:title];
		return;
	}else{
		if(mode2_dirIsForward){
			mode2_currentRange = NSMakeRange(range.location, (textLen - range.location));
		}else{
			// do nothing
		}
		title = [NSString stringWithFormat:NSLocalizedString(@"Vi: %@I-Search", @""),
			(searchIsWrapping ? @"Wrapped " : @"")];
		
		if(!mode2_dirIsForward) title = [title stringByAppendingString:NSLocalizedString(@" backward",@"")];
		
		searchIsFirstTime = NO;
		searchIsWrapping = NO;
		[self  reflectAction:title];
	}
	

  [firstResponder setSelectedRange:range];
  [firstResponder scrollRangeToVisible:range];
#endif
	
	
}




- (void)handleMode3 {

	int len = [cmdString length];
	
	// first thing is a sanity check
	//  the cmdString should be 2 or more characters long
	if (len < 2)
	{
		// try to gracefully recover
		[textField setStringValue:@""];
		mode = 0;
		return;
	}
	
	// second thing to do is to see if the last character of the cmdString is a number
	//  if it is a number, then we just drop out and let the user continue typing
	unichar c = [cmdString characterAtIndex:(len-1)];
	if (isdigit(c)) 
	{
	  saveCmdString=1;
	  return;
	}
	

	NSString* lastKey = [cmdString substringFromIndex:(len-1)];
	if ([lastKey isEqualToString:@"G"])
	{
    NSRange numRange = NSMakeRange(0,len-1);
		NSString* numStr = [cmdString substringWithRange:numRange];
		int lineNo = [numStr intValue];
		[self reflectAction:[NSString stringWithFormat:@"Vi: (G) Moving to line %i",lineNo]];
#ifdef __TEXTMATE__
    [firstResponder goToLineNumber:numStr];
#else
	
		int index = [self getIndexForLineNumber:lineNo 
									ofString:[firstResponder string]];
					
		NSRange cR = NSMakeRange(index,1);
		[firstResponder setSelectedRange:cR];
#endif
	}
	else if([lastKey isEqualToString:@"s"])
	{
		int i;
    NSRange numRange = NSMakeRange(0,len-1);
		NSString* numStr = [cmdString substringWithRange:numRange];
		int count = [numStr intValue];
		id window = [NSApp mainWindow];
		
		[self reflectAction:[NSString stringWithFormat:@"Vi: (s) Substituting %i Characters", count]];
		
		
		// Clear Possible selection
		[firstResponder performSelector: @selector(moveRight:) withObject:window];
		[firstResponder performSelector: @selector(moveLeft:) withObject:window];
		for( i = 0; i < count; i += 1 ) 
		{
			[firstResponder performSelector: @selector(moveForwardAndModifySelection:) withObject:window];
		}
		[firstResponder deleteForward:nil];
	  
    [[self window] orderOut:self];
	}
	else
		NSBeep();
		
	// clean up is the same for any of the fall-outs too
	saveCmdString=0;
	mode = 0;

}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
	
	return NO;
}



- (void)handleMode4 {

	int len = [cmdString length];
	
	// first thing is a sanity check
	//  the cmdString should be 2 characters long
	if (len != 2)
	{
		// try to gracefully recover
		[textField setStringValue:@""];
		saveCmdString = 0;
		mode = 0;
		return;
	}

	NSString* newStr = [cmdString substringFromIndex:(len-1)];
#ifdef __TEXTMATE__
	int i;
	id window = [NSApp mainWindow];
	// Clear possible selections
	[firstResponder performSelector: @selector(moveRight:) withObject:window];
	[firstResponder performSelector: @selector(moveLeft:) withObject:window];
	for( i = 1; i < len; i += 1 ) 
	{
		[firstResponder performSelector: @selector(moveForwardAndModifySelection:) withObject:window];
	}

	[firstResponder insertText:newStr];
	
#else
	NSRange cR = [firstResponder selectedRange];
	cR.length = 1;
	[firstResponder replaceCharactersInRange:cR withString:newStr];
	[firstResponder setSelectedRange:cR];
#endif
	saveCmdString = 0;
	mode = 0;
}



/** This message is issued only when the cmd string is complete (and user hits enter) 
  *  The commands are handled by issuing mnemonics to the program.  This has potential pitfalls,
  *  but since there are no applications hooks, I think it may be the only way to doing it.
  */
- (void)handleMode5 {

	NSDate* now;
	NSWindow* win;
	NSEvent* e;
	int len = [cmdString length];
	
	// then we don't have to do anything
	if (len < 2)
		return;
		
	// otherwise, let's check the second character to see what we should do
	unichar c = [cmdString characterAtIndex:1];
	switch (c)
	{
		case 'w':
#if 0 
			now = [NSDate date]; 
			win = [firstResponder window];
			e = [NSEvent keyEventWithType:NSKeyDown
			                              location:NSMakePoint(0,0)
								     modifierFlags:NSCommandKeyMask
									     timestamp:[now timeIntervalSinceNow]
									  windowNumber:[win windowNumber]
									       context:[win graphicsContext]
										characters:@"@s"
					   charactersIgnoringModifiers:@"s"
										 isARepeat:NO
										   keyCode:0x1];
			[win postEvent:e atStart:NO];
#else
      [NSApp sendAction:@selector(saveDocument:) to:nil from:nil];
#endif
		break;
	}
	
}

// ADDED  by Jerome Duquennoy (2 Feb 07) ---------------------------
- (void)windowDidResignKey:(NSNotification*)notification
{
	[textField setStringValue:@""];
	[self setMode:ViInsertMode];
  [[self window] close];
	
	lastOakViewSize = NSMakeSize(currentOakViewSize.width, currentOakViewSize.height);
}

- (void)setMode:(ViMode)theMode
{
  [currentCursorView setMode:theMode];
  currentMode = theMode;
}

- (ViMode)getMode
{
  return currentMode;
}

- (void)keyDown:(NSEvent *)theEvent
{
	printf("test\n");
}
//----------------------------------
// TEXTMATE
- (void)setSelectedRange:(NSRange)cRange withResponder:(id)responder
{ 

	//[responder setMarkedText:nil selectedRange:cRange];
	//[responder showCaret];
//	[responder performSelector:@selector(moveForwardAndModifySelection:) withObject:[NSApp mainWindow]];
//	[responder performSelector:@selector(moveBackwardAndModifySelection:) withObject:[NSApp mainWindow]];
}
@end
