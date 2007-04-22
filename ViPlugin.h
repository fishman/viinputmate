//
//  ViPlugin.h
//  ViMate
//
//  Created by Kirt Fitzpatrick on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TMPlugInController
- (float)version;
@end


@interface ViPlugin : NSObject {

}
- (id)initWithPlugInController:(id <TMPlugInController>)aController;
@end
