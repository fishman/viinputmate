//
//  ViPlugin.m
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ViPlugin.h"
#import "ViWindow.h"


@implementation ViPlugin
- (id)initWithPlugInController:(id <TMPlugInController>)aController
{
	NSLog( @"we have lift off!" );
	[ViWindow poseAsClass:[NSWindow class]];
	
	return [super init];
}
@end
