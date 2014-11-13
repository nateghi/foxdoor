//
//  User.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 04/02/2013.
//
//

#import <Foundation/Foundation.h>




@interface User : NSObject <NSCoding>

@property(strong, nonatomic) NSString *registered;
@property(strong, nonatomic) NSString *UUID;

@property(strong, nonatomic) NSString *registrationID;
@property(strong, nonatomic) NSString *email;
@property(strong, nonatomic) NSString *mobileNo;

@property(strong, nonatomic) NSString *password;

@property(strong, nonatomic) NSString *fullName;
@property(strong, nonatomic) NSString *DOB;

@property(strong, nonatomic) NSString *houseNo;
@property(strong, nonatomic) NSString *flatNo;
@property(strong, nonatomic) NSString *postcode;

@property(strong, nonatomic) NSString *customerID;

- (NSDictionary *)dictionaryRepresentation;

@end
