//
//  Payment.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 14/04/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Payment : NSObject

@property(strong, nonatomic) NSString *paymentID;
@property(strong, nonatomic) NSString *businessName;
@property(strong, nonatomic) NSString *branch;
@property(strong, nonatomic) NSNumber *amount;
@property(strong, nonatomic) NSString *propertyNumber;
@property(strong, nonatomic) NSString *street;
@property(strong, nonatomic) NSString *town;
@property(strong, nonatomic) NSString *postCode;
@property(strong, nonatomic) NSString *telephoneNumber;

@end
