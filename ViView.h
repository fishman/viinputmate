//
//  ViView.h
//  ViMate
//
//  Created by Rodrigue Cloutier on 18/06/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViMode.h"

@interface ViView : NSView {
    ViMode mode;
	NSColor * caretColor;
}

- (void)setMode:(ViMode)theMode;
- (void)setCaretColor:(NSColor*)color;

@end
