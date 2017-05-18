//
//  AppDelegate.m
//  Clicker
//
//  Created by Jonathan Aceituno on 03/03/2017.
//  Copyright © 2017 À la Bonne Sainte-Force. All rights reserved.
//

#import "AppDelegate.h"
#import <ApplicationServices/ApplicationServices.h>

@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize clickerController = _clickerController;

+(BOOL)askEnableAccessibilityIfNeeded
{
	BOOL enabled = NO;
	BOOL onMavericks = AXIsProcessTrustedWithOptions != NULL;
	if(onMavericks) {
		enabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)@{(id)kAXTrustedCheckOptionPrompt: @NO});
		if(!enabled) {
			NSAlert *alert = [NSAlert alertWithMessageText:@"Access to accessibility features required." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"In order to run this application, you have to grant it access to accessibility features. A dialog will appear explaining how to do it. When done, please restart this application."];
			[alert runModal];
			AXIsProcessTrustedWithOptions((CFDictionaryRef)@{(id)kAXTrustedCheckOptionPrompt: @YES});
		}
	} else {
		enabled = AXIsProcessTrusted() || AXAPIEnabled();
		if(!enabled) {
			NSString *messageText = [NSString stringWithFormat:@"\"%@\" would like to control this computer using accessibility features.", [[NSRunningApplication currentApplication] localizedName]];
			NSAlert *alert = [NSAlert alertWithMessageText:messageText defaultButton:@"Deny" alternateButton:@"Open System Preferences" otherButton:nil informativeTextWithFormat:@"In order to run this program, you have to grant it access to accessibility features.\nTo do so, please open the \"Universal Access\" pane in System Preferences and check \"Enable access for assistive devices\".\nWhen done, please restart the application."];
			NSUInteger result = [alert runModal];
			if(result == NSAlertAlternateReturn) {
				NSURL *openPreferencesScriptURL = [[NSBundle mainBundle] URLForResource:@"OpenUniversalAccess" withExtension:@"applescript"];
				NSString *openPreferencesScriptSource = [NSString stringWithContentsOfURL:openPreferencesScriptURL encoding:NSUTF8StringEncoding error:NULL];
				NSAppleScript *openPreferencesScript = [[NSAppleScript alloc] initWithSource:openPreferencesScriptSource];
				[openPreferencesScript executeAndReturnError:NULL];
				[openPreferencesScript release];
			}
		}
	}
	return enabled;
}

+(void)askEnableAccessibilityAndQuitIfNeeded
{
	if(![self askEnableAccessibilityIfNeeded]) {
		[[NSApplication sharedApplication] terminate:self];
	}
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[[self class] askEnableAccessibilityAndQuitIfNeeded];
	self.clickerController = [[[ClickerController alloc] init] autorelease];
	[self.clickerController start];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	[self.clickerController stop];
	self.clickerController = nil;
}


@end
