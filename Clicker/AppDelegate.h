//
//  AppDelegate.h
//  Clicker
//
//  Created by Jonathan Aceituno on 03/03/2017.
//  Copyright © 2017 À la Bonne Sainte-Force. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ClickerController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	ClickerController *_clickerController;
}
@property (nonatomic, strong) ClickerController *clickerController;
@end

