//
//  AsteroidsAppDelegate.m
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//

#import "AsteroidsAppDelegate.h"
#import "VKViewController.h"

@implementation AsteroidsAppDelegate
@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    VKViewController *viewController = [[VKViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    self.window.tintColor = [UIColor yellowColor];
    
    return YES;
}

@end
