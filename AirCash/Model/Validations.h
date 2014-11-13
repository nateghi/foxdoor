//
//  Validations.h
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Validations : NSObject

+ (BOOL)CanValidateEmailFormat:(NSString *)email;

+ (BOOL)CanValidatePnoeNumber:(NSString *)number;

@end
