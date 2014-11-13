//
//  Card.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 14/04/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import "Card.h"
#import <objc/runtime.h>

@implementation Card

@synthesize cardNumber, exirpyDate, nameOnCard, cardType, cvc, HouseNumber, StreetName, PostCode, issueNumber, Token;


-(id)initWithDictionary :(NSDictionary*)dictionary{
    
    if ([super init]) {
        
        self.cardNumber = [dictionary objectForKey:@"cardNumber"];
		self.expirationYear = [dictionary objectForKey:@"expirationYear"];
		self.expirationMonth = [dictionary objectForKey:@"expirationMonth"];
        self.nameOnCard = [dictionary objectForKey:@"cardHolderName"];
        self.cardType = [dictionary objectForKey:@"cardType"];
        self.cvc = [dictionary objectForKey:@"CVNCode"];
        self.HouseNumber = [dictionary objectForKey: @"houseNumber"];
		self.PostCode = [dictionary objectForKey:@"postCode"];
		self.StreetName = [dictionary objectForKey:@"streetName"];
        self.issueNumber = [dictionary objectForKey:@"issueNumber"];
		self.Token = [dictionary objectForKey:@"Token"];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    unsigned int count = 0;
    // Get a list of all properties in the class.
	objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    
	for (int i = 0; i < count; i++) {
		NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
		NSString *value = [self valueForKey:key];
		
		// Only add to the NSDictionary if it's not nil.
		if (value)
			[dictionary setObject:value forKey:key];
	}
    //
	free(properties);
    
    return dictionary;
}

- (NSString *)exirpyDate
{
	return [NSString stringWithFormat:@"%@ / %@", self.expirationMonth, self.expirationYear];
}

@end
