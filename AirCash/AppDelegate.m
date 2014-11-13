//
//  AppDelegate.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 14/04/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "KeychainItemWrapper.h"
#import "PaymentDetailViewController.h"
#import "SignUpViewController.h"
#import "LogInViewController.h"
#import "Reachability.h"
#import "NSData+Base64.h"
#import "RootViewController.h"

#import "Constants.h"
@implementation AppDelegate

@synthesize userDetails = _userDetails;

@synthesize navigationController=_navigationController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
    
    KeychainItemWrapper *userWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"account" accessGroup:nil];
    _userDetails = [[User alloc]init];
    
    NSString *decodedString = [userWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSData *decodedData = [NSData dataWithBase64EncodedString:decodedString];
    
    if (decodedData) {
        
        _userDetails = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    }
	self.pointer = -1;
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceToken = token;
	
    if ([_userDetails.registered isEqualToString:@"YES"] ) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        [reach startNotifier];
        
        NSString *urlString = [BASE_URL stringByAppendingString:@"Service/Service/UpdateCustomerNotificationInfo/"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:token, @"DeviceToken", nil];
        
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                           options:NSJSONWritingPrettyPrinted error:nil];
        if (!jsonData) {
        } else {
            
//            NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        }
        
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        [request addValue:_userDetails.registrationID forHTTPHeaderField:@"X-CustomerId"];
        [request addValue:[_userDetails.password base64EncodedString] forHTTPHeaderField:@"X-Password"];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             
             NSString* responseString;
             responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
             
             if (httpResponse.statusCode == 200) {}
         }];
        
    }
    
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        
    }
    else
    {
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Connectivity Problem"
                                                               message:@"You need to connect your mobile to 3G or WiFi"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	[[[UIAlertView alloc] initWithTitle:nil message:@"We need you to enable push notification to porvide better services for you.\n Please enable it in settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    
    if([application applicationState] == UIApplicationStateActive) // Foreground
    {
        [self handleRemoteNotification:userInfo withAlert:YES];
    }else { // Background
        [self handleRemoteNotification:userInfo withAlert:NO];
    }
    
	
}

-(void)handleRemoteNotification: (NSDictionary *)userInfo withAlert: (BOOL)alret{
    
	
    if (alret) {
		
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"PaymentRequestNotification"
         object:userInfo];
        
		//        MasterViewController *master = (MasterViewController*) self.window.rootViewController;
		//        [master loadPaymentRequests];
        
    } else{
        
        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Payment Request"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}









@end
