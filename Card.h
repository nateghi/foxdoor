//
//  Card.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 03/02/2013.
//
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property(strong, nonatomic) NSString *cardNumber;
@property(strong, nonatomic, readonly) NSString *exirpyDate;
@property(strong, nonatomic) NSString * expirationMonth;
@property(strong, nonatomic) NSString * expirationYear;
@property(strong, nonatomic) NSString *nameOnCard;
@property(strong, nonatomic) NSString *cardType;
@property(strong, nonatomic) NSString *cvc;

@property(strong, nonatomic)NSString *HouseNumber;
@property(strong, nonatomic)NSString *PostCode;
@property(strong, nonatomic)NSString *StreetName;

@property(strong, nonatomic)NSString *issueNumber;
@property(strong, nonatomic)NSString *Token;

-(id)initWithDictionary :(NSDictionary*)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end
