/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  TwilioPlugin
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "PushNotification.h"
#import <Cordova/CDVPlugin.h>

@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end


@implementation AppDelegate

@synthesize window, viewController;

- (id)init
{
    /** If you need to do any extra app-specific initialization, you can do it here
     *  -jm
     **/
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];

    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
    NSURLCache* sharedCache = [[[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"] autorelease];
    [NSURLCache setSharedURLCache:sharedCache];

    self = [super init];
    return self;
}

#pragma mark UIApplicationDelegate implementation

/**
 * This is main kick off after the app inits, the views and Settings are setup here. (preferred - iOS4 and up)
 */
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    NSLog(@"sadnalsd");
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    self.window.autoresizesSubviews = YES;

    self.viewController = [[[MainViewController alloc] init] autorelease];
    self.viewController.useSplashScreen = YES;

    // Set your app's start page by setting the <content src='foo.html' /> tag in config.xml.
    // If necessary, uncomment the line below to override it.
     self.viewController.startPage = @"index.html";

    // NOTE: To customize the view's frame size (which defaults to full screen), override
    // [self.viewController viewWillAppear:] in your view controller.

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo) {
        PushNotification *pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
        NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
        [mutableUserInfo setValue:@"1" forKey:@"applicationLaunchNotification"];
        [mutableUserInfo setValue:@"0" forKey:@"applicationStateActive"];
        [pushHandler.pendingNotifications addObject:mutableUserInfo];
    }
    return YES;
}


// this happens while we are running ( in the background, or from within our own app )
// only valid if TwilioPlugin-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url) {
        return NO;
    }
    
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];

    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    return YES;
}


// repost the localnotification using the default NSNotificationCenter so multiple plugins may respond
- (void)application:(UIApplication*)application
    didReceiveLocalNotification:(UILocalNotification*)notification
{
    
    
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);

    return supportedInterfaceOrientations;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}
/*-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  /*
	deviceid=[NSUserDefaults standardUserDefaults];
    if ([deviceid objectForKey:@"devicetoken" ]==NULL)
    {
        [deviceid setValue:deviceToken forKey:@"devicetoken"];
        
        NSLog(@"get device token-->%@",deviceToken);
        
        NSString *strToken = [NSString stringWithFormat:@"%@",deviceToken];
        NSString *strTokenWithoutSpaces = [[[NSString alloc]init]autorelease];
        strTokenWithoutSpaces = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        strTokenWithoutSpaces = [strTokenWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
        strTokenWithoutSpaces = [strTokenWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
        NSLog(@"strTokenWithoutSpaces%@",strTokenWithoutSpaces);
        
        // tokenStr=[[NSString stringWithString:str]retain];
        [[NSUserDefaults standardUserDefaults] setValue:strTokenWithoutSpaces forKey:@"TokenString"];
        
    }
    
    else
    {
        NSString *getdevice=[NSString stringWithFormat:@"%@",[deviceid objectForKey:@"devicetoken"]];
        if([[NSString stringWithFormat:@"%@",deviceToken] isEqualToString:getdevice])
        {
            NSLog(@"get device token-->%@",deviceToken);
        }
        else
        {
            
            
            NSLog(@"get device token-->%@",deviceToken);
            
            
            //This code is for deleting the device token on server.
            NSString *strToken1 = [NSString stringWithFormat:@"%@",[deviceid objectForKey:@"devicetoke"]];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"devicetoke"];
            NSString *strTokenWithoutSpaces1 = [[[NSString alloc]init]autorelease];
            strTokenWithoutSpaces1 = [strToken1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            strTokenWithoutSpaces1 = [strTokenWithoutSpaces1 stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strTokenWithoutSpaces1 = [strTokenWithoutSpaces1 stringByReplacingOccurrencesOfString:@">" withString:@""];
            NSLog(@"strTokenWithoutSpaces2%@",strTokenWithoutSpaces1);
            
            
            [deviceid setValue:deviceToken forKey:@"devicetoken"];
            //  NSLog(@"Return data = %@",returnData1);
            
            
            
            
            //this is for updating the device token
            
            NSString *strToken = [NSString stringWithFormat:@"%@",deviceToken];
            NSString *strTokenWithoutSpaces = [[[NSString alloc]init]autorelease];
            strTokenWithoutSpaces = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];
            strTokenWithoutSpaces = [strTokenWithoutSpaces stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strTokenWithoutSpaces = [strTokenWithoutSpaces stringByReplacingOccurrencesOfString:@">" withString:@""];
            NSLog(@"strTokenWithoutSpaces3%@",strTokenWithoutSpaces);
            
        }
    }
    
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *message=[[NSDictionary alloc]initWithDictionary:[userInfo objectForKey:@"aps"]];
    NSLog(@"alert-->%@",message);
    NSLog(@"get the dictionary---->%@",userInfo);
    NSString *string=[[NSString alloc]initWithFormat:@"%@",[message objectForKey:@"alert"]];
    UIApplicationState state = [application applicationState];
    NSLog(@"%@",string);
    [[NSUserDefaults standardUserDefaults]setObject:string forKey:@"alertMessage"];
    // getMessage = string;
    // NSLog(@"%@", getMessage);
    if (state == UIApplicationStateActive)
    {
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Call-Center" message:string delegate:self cancelButtonTitle:@"Close" otherButtonTitles: @"Open", nil] autorelease];
        [alert setTag: 1];
        [alert show];
        //  NSLog(@"%@",message1);
    }
    
    else if(state==UIApplicationStateBackground)
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"CallCenter" message:string delegate:self cancelButtonTitle:@"Close" otherButtonTitles: @"Open", nil] autorelease];
        [alert setTag: 2];
        [alert show];
        NSLog(@"%@",string);
        
    }
    else if(state==UIApplicationStateInactive) {
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Call-Center" message:string delegate:self cancelButtonTitle:@"Close" otherButtonTitles: @"Open", nil] autorelease];
        [alert setTag: 3];
        [alert show];
        NSLog(@"%@",string);
        
    }
    
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}*/
- (void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    PushNotification* pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
    [pushHandler didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    PushNotification* pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
    [pushHandler didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    PushNotification* pushHandler = [self.viewController getCommandInstance:@"PushNotification"];
    NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
    
    // Get application state for iOS4.x+ devices, otherwise assume active
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [mutableUserInfo setValue:@"0" forKey:@"applicationLaunchNotification"];
    if (appState == UIApplicationStateActive) {
        [mutableUserInfo setValue:@"1" forKey:@"applicationStateActive"];
        [pushHandler didReceiveRemoteNotification:mutableUserInfo];
    } else {
        [mutableUserInfo setValue:@"0" forKey:@"applicationStateActive"];
        [mutableUserInfo setValue:[NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
        [pushHandler.pendingNotifications addObject:mutableUserInfo];
    }
}
@end
