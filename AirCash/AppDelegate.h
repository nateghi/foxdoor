//
//  AppDelegate.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 14/04/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) User *userDetails;

@property (nonatomic) IBOutlet UINavigationController *navigationController;


//@property (strong, nonatomic) NSMutableArray *PaymentRequests;
@property(assign, nonatomic) int pointer;
@property(strong, nonatomic) NSString *deviceToken;

@property (weak, nonatomic) UIButton *selectBtn;

@end
