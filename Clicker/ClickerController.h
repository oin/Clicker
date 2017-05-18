//
//  ClickerController.h
//  Clicker
//
//  Created by Jonathan Aceituno on 03/03/2017.
//  Copyright © 2017 À la Bonne Sainte-Force. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface ClickerController : NSObject
{
	BOOL down_;
	CGMouseButton which_;
	
	unsigned _keyCode;
	
	mach_port_t eventDriver;
	
	CFMachPortRef eventTap;
	CFRunLoopSourceRef runLoopSource;
}
@property (nonatomic, assign) unsigned keyCode;
-(void)start;
-(void)stop;
@end
