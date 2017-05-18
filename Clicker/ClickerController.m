//
//  ClickerController.m
//  Clicker
//
//  Created by Jonathan Aceituno on 03/03/2017.
//  Copyright © 2017 Jonathan Aceituno. All rights reserved.
//

#import "ClickerController.h"
#import <IOKit/hidsystem/IOHIDLib.h>

@interface ClickerController ()
@property (nonatomic, assign) BOOL down;
@property (nonatomic, assign) CGMouseButton which;
-(CFMachPortRef)tap;
-(void)triggerMouseButton:(CGMouseButton)button down:(BOOL)down;
@end

CGEventRef ClickerEventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *context) {
	if(type == -1) return event;
	ClickerController *me = (ClickerController *)context;
	if(me) {
		if(type == kCGEventTapDisabledByTimeout) {
			CGEventTapEnable(me.tap, YES);
			return event;
		}
		BOOL isDown = type == kCGEventKeyDown;
		if(isDown || type == kCGEventKeyUp) {
			int64_t code = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
			if(code == me.keyCode) {
				if(isDown) {
					BOOL rightClick = ((CGEventGetFlags(event) & kCGEventFlagMaskControl) != 0);
					me.which = rightClick? kCGMouseButtonRight : kCGMouseButtonLeft;
				}
				if(!isDown || CGEventGetIntegerValueField(event, kCGKeyboardEventAutorepeat) == 0) {
					[me triggerMouseButton:kCGMouseButtonLeft down:isDown];
					me.down = isDown;
				}
				return NULL;
			}
		} else if(type == kCGEventMouseMoved && me.down) {
			// Fix for macOS 10.12
			CGEventSetType(event, me.which == kCGMouseButtonRight? kCGEventRightMouseDragged : kCGEventLeftMouseDragged);
		}
	}
	return event;
}

@implementation ClickerController
@synthesize down = down_;
@synthesize which = which_;

-(instancetype)init
{
	self = [super init];
	if(self) {
		_keyCode = 110; // << Change this key code if you want (by default, set to PC_APPLICATION)
		down_ = NO;
		which_ = kCGMouseButtonLeft; // << Change this mouse button if you want
		
		// Initialize the IOKit event driver
		mach_port_t masterPort;
		IOMasterPort(bootstrap_port, &masterPort);
		mach_port_t service;
		service = IOServiceGetMatchingService(masterPort, IOServiceMatching(kIOHIDSystemClass));
		IOServiceOpen(service, mach_task_self(), kIOHIDParamConnectType, &eventDriver);
		IOObjectRelease(service);
		
		// Initialize the event tap
		CGEventMask mask = CGEventMaskBit(kCGEventKeyDown)|CGEventMaskBit(kCGEventKeyUp);
		if(NSAppKitVersionNumber >= NSAppKitVersionNumber10_12) {
			// Sierra doesn't automatically translate mouse moves into dragging events, so we'll have to do it ourselves.
			mask |= CGEventMaskBit(kCGEventMouseMoved);
		}
		eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, mask, ClickerEventTapCallback, self);
		runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
	}
	return self;
}

- (void)dealloc
{
	[self stop];
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
	CFRelease(eventTap);
	CFRelease(runLoopSource);
	IOServiceClose(eventDriver);
	[super dealloc];
}

-(void)start
{
	CGEventTapEnable(eventTap, YES);
}

-(void)stop
{
	if(down_) {
		[self triggerMouseButton:kCGMouseButtonLeft down:NO];
	}
	CGEventTapEnable(eventTap, NO);
}

-(CFMachPortRef)tap
{
	return eventTap;
}

-(void)triggerMouseButton:(CGMouseButton)button down:(BOOL)down
{
	NXEventData eventData;
	bzero(&eventData, sizeof(eventData));
	
	UInt32 type = NX_LMOUSEDOWN;
	if(button == kCGMouseButtonLeft) {
		type = down? NX_LMOUSEDOWN : NX_LMOUSEUP;
	} else if(button == kCGMouseButtonRight) {
		type = down? NX_RMOUSEDOWN : NX_RMOUSEUP;
	} else {
		type = down? NX_OMOUSEDOWN : NX_OMOUSEUP;
	}
	
	eventData.mouse.buttonNumber = button;
	eventData.mouse.click = down;
	eventData.mouse.eventNum = CGEventSourceCounterForEventType(kCGEventSourceStateHIDSystemState, type) + 1;
	eventData.mouse.pressure = down? 255 : 0;
	eventData.mouse.subType = 9;
	
	IOHIDPostEvent(eventDriver, type, (IOGPoint){0,0}, &eventData, kNXEventDataVersion, (IOOptionBits)CGEventSourceFlagsState(kCGEventSourceStateHIDSystemState), kIOHIDPostHIDManagerEvent);
}

@end
