//
//  SignUpManager.h
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol SignUpDelegate <NSObject>

@optional

- (void)failedPreRegisterWithMessage:(NSString *)message;

- (void)successfulPreRegister;

- (void)failedRegister;

- (void)successfulRegister;

- (void)codesHasBeenVerified;

- (void)codeVerificationFailed;

- (void)smsCodeHasBeenSent;

- (void)failedToSendSMSCode;

@end

@interface SignUpManager : NSObject

@property (nonatomic, strong) User * User;

@property (nonatomic, weak) NSObject<SignUpDelegate> * Delegate;

+(instancetype) Manager;

- (void)initialSignUp;

- (void)finishSignUp;

- (void)verifySmsCode:(NSString *)smsCode EmailCode:(NSString *)emailCode;

- (void)resendVerificationCodes;

@end
