#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "MainViewController.h"
#import "FlutterAppDelegate+Pjsip.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    /** 设置主控制器继承FlutterViewController*/
    MainViewController * VC = [[MainViewController alloc]init];
    UINavigationController * NVC = [[UINavigationController alloc]initWithRootViewController:VC];
    [self.window setRootViewController:NVC];
//    FlutterViewController * VC = [[FlutterViewController alloc]init];
    [self setupPjsip:application rootController:VC];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
