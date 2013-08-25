//
//  HelloOpenGLAppDelegate.h
//  HelloOpenGL
//
//  Created by Ray Wenderlich on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VKViewController.h"

@interface HelloOpenGLAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic ,strong) IBOutlet VKViewController *viewController;

@end
