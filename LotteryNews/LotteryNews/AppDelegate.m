//
//  AppDelegate.m
//  LotteryNews
//
//  Created by 邹壮壮 on 2016/12/20.
//  Copyright © 2016年 邹壮壮. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "LNTabBarVC.h"
#import "WXApiManager.h"
#import "LNLottoryConfig.h"
#import "UserStore.h"
#import "LNUserInfoModel.h"
#import "StoreManager.h"
#import <Bugly/Bugly.h>
#import "HRSystem.h"
#import <UMMobClick/MobClick.h>
#import "HRNetworkTools.h"
#import "XHLaunchAd.h"
#import "CoverViewController.h"
@interface AppDelegate ()<LoginViewControllerDelegate,UITabBarControllerDelegate>
@property (nonatomic, strong) LNTabBarVC *LNTabBarViewController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"ok");
    if (!UserDefaultObjectForKey(LOTTERY_HOST_NAME_SEVER)) {
        UserDefaultSetObjectForKey(@"https://caipiao.asopeixun.com:6688", LOTTERY_HOST_NAME_SEVER);
    }
    [WXApi registerApp:kAuthOpenID withDescription:@"demo 2.0"];
    BuglyConfig *bugConfig = [[BuglyConfig alloc]init];
    bugConfig.blockMonitorEnable = YES;
    bugConfig.unexpectedTerminatingDetectionEnable = YES;
    bugConfig.debugMode = YES;
    bugConfig.channel = [HRSystem appName];
    bugConfig.version = [HRSystem bundleVersion];
    [Bugly startWithAppId:kBuglyAppid config:bugConfig];
    
    UMConfigInstance.appKey = UM_appkey;
    [MobClick startWithConfigure:UMConfigInstance];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self adViewController];
   
    [self.window makeKeyAndVisible];
    [[StoreManager sharedInstance]startManager];
    return YES;
}
- (void)adViewController{
    CoverViewController *coverVC = [[CoverViewController alloc]initWithFrame:CGRectMake(0, 0,self.window.bounds.size.width, self.window.bounds.size.height) showFinish:^{
        
        self.LNTabBarViewController = [[LNTabBarVC alloc] init];
        self.LNTabBarViewController.delegate = self;
        self.window.rootViewController = self.LNTabBarViewController;
       
    }];
    self.window.rootViewController = coverVC;
 

}
/**
 *  模拟:向服务器请求广告数据
 *
 *  @param imageData 回调imageUrl,及停留时间,跳转链接
 */
-(void)requestImageData:(void(^)(NSString *imgUrl,NSInteger duration,NSString *openUrl))imageData{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(imageData)
        {
            imageData(nil,3,@"http://www.returnoc.com");
        }
    });
}


- (void)userLoginSucess{

    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {

   
    [[StoreManager sharedInstance]startManager];
   
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
        return YES;
    
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
        return YES;
}
//竖屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}
#pragma mark --<UITabBarControllerDelegate>
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    NSString *userID = UserDefaultObjectForKey(LOTTORY_AUTHORIZATION_UID);
    if ((viewController == tabBarController.viewControllers[2]&&!userID) || (viewController == tabBarController.viewControllers[4]&&!userID)) {
        LoginViewController *loginVC = [[LoginViewController alloc]init];
        loginVC.delegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:loginVC animated:YES completion:nil];
        return NO;
    }else{
        return YES;
    }
}
@end
