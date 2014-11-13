//
//  CardRegisteration.h
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CardRegisterationDelegate <NSObject>

@optional

- (void)didDuccessfullyGetToken:(NSString *)token;

- (void)didFailToGetTokenWithErrorDescription:(NSString *)error;

- (void)registeredSuccessfully;

- (void)registerationFailedWithError:(NSString *)error;

- (void)didTimeOutProblem;

@end

@interface CardRegisteration : NSObject

@property (nonatomic, strong) NSObject<CardRegisterationDelegate> * Delegate;

- (void)submitWithName:(NSString *)Name cardNumber:(NSString *)cardNumber CVC:(NSString *)cvc withExpirationYear:(NSString *)expirationYear withExpirationMonth:(NSString *)expirationMonth cardType:(NSString *)cardType issueNumber:(NSString *)issueNumber;


- (void)finalizeRegisterationWithHouseNumberOrName:(NSString *)houseNomber postCode:(NSString *)postCode streetName:(NSString *)streetName;


- (void)dissmiss;

@end
