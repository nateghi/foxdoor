//
//  User.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 04/02/2013.
//
//

#import "User.h"

@implementation User

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.mobileNo forKey:@"mobileNo"];
    [encoder encodeObject:self.password forKey:@"password"];
    [encoder encodeObject:self.fullName forKey:@"fullName"];
    [encoder encodeObject:self.DOB forKey:@"DOB"];
    [encoder encodeObject:self.houseNo forKey:@"houseNo"];
    [encoder encodeObject:self.flatNo forKey:@"flatNo"];
    [encoder encodeObject:self.postcode forKey:@"postcode"];
    [encoder encodeObject:self.registrationID forKey:@"registrationID"];
    [encoder encodeObject:self.registered forKey:@"registered"];
	[encoder encodeObject:self.UUID forKey:@"uuid"];
	[encoder encodeObject:self.customerID forKey:@"CustomerID"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        self.email = [decoder decodeObjectForKey:@"email"];
        self.mobileNo = [decoder decodeObjectForKey:@"mobileNo"];
        self.password = [decoder decodeObjectForKey:@"password"];
        self.fullName = [decoder decodeObjectForKey:@"fullName"];
        self.DOB = [decoder decodeObjectForKey:@"DOB"];
        self.houseNo = [decoder decodeObjectForKey:@"houseNo"];
        self.flatNo = [decoder decodeObjectForKey:@"flatNo"];
        self.postcode = [decoder decodeObjectForKey:@"postcode"];
        self.registrationID = [decoder decodeObjectForKey:@"registrationID"];
        self.registered = [decoder decodeObjectForKey:@"registered"];
        self.UUID = [decoder decodeObjectForKey:@"uuid"];
		self.UUID = [decoder decodeObjectForKey:@"CustomerID"];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    unsigned int count = 0;
    // Get a list of all properties in the class.
//    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:count];
    
//    for (int i = 0; i < count; i++) {
//        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
//        NSString *value = [self valueForKey:key];
//        
//        // Only add to the NSDictionary if it's not nil.
//        if (value)
//            [dictionary setObject:value forKey:key];
//    }
//    
//    free(properties);
    
    return dictionary;
}

@end
