//
//  LoginManager.h
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    UserNameOrPasswordProblem,
	UnknownProblem
} AuthenticationProblems;

@protocol LoginDelegate <NSObject>

@required

- (void)Authenticated;

- (void)NotAuthenticatedWithType:(AuthenticationProblems)type;

@end

@interface LoginManager : NSObject

@property (nonatomic, weak) NSObject<LoginDelegate> * Delegate;

- (void)authenticateWithUserName:(NSString *)userName password:(NSString *)password;

- (void)beginAutoLogin;

- (BOOL)isUserRegistered;

@end
