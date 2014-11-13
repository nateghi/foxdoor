//
//  LoginManager.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "LoginManager.h"
#import "User.h"
#import "Constants.h"
#import "KeychainItemWrapper.h"
#import "NSData+Base64.h"


@interface LoginManager()
{
	User * userDetails;
}

@end

@implementation LoginManager

@synthesize Delegate;

- (void)authenticateWithUserName:(NSString *)userName password:(NSString *)password
{
	User * user = [[User alloc] init];
	user.email = userName;
	user.password = password;
	@try {
		[self sendDataToServer:user];
	}
	@catch (NSException *exception) {
		[Delegate NotAuthenticatedWithType:UnknownProblem];
	}
	@finally {
	}
}

- (void)sendDataToServer:(User *)user
{
	NSDictionary *customerCredentials = @{@"Email":user.email, @"Password":user.password};
	NSData* jsonData = [NSJSONSerialization dataWithJSONObject:customerCredentials
													   options:NSJSONWritingPrettyPrinted error:nil];
	
	NSString *urlString = [BASE_URL stringByAppendingString:@"Service/Service/LoginCustomer/"];
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:jsonData];
	
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	
	NSOperationQueue *queue = [NSOperationQueue mainQueue];
	
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	 {
		 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		 
		 if (httpResponse.statusCode == 200) {
			 
			 NSString* responseString;
			 responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			 int responseINT = [responseString intValue];
			 
			 if (responseINT > 0 ) {
				 
				 user.registrationID = responseString;
				 
				 NSData *data = [ NSKeyedArchiver archivedDataWithRootObject:user];
				 
				 NSString *encodedString= [data base64EncodedStringWithOptions:0];
				 KeychainItemWrapper *userWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"account" accessGroup:nil];
				 [userWrapper setObject:encodedString forKey:(__bridge id)(kSecAttrAccount)];
				 
				 [Delegate Authenticated];
			 } // If responseINT
			 
			 else if (responseINT <1 ){
				 [Delegate NotAuthenticatedWithType:UserNameOrPasswordProblem];
				 return;
			 }
			 
		 }
		 else {
			 [Delegate NotAuthenticatedWithType:UserNameOrPasswordProblem];
		 }
	 }];
}

- (void)beginAutoLogin
{
	if ([self isUserRegistered]) {
		[self sendDataToServer:userDetails];
	}
}

- (BOOL)isUserRegistered
{
	KeychainItemWrapper *userWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"account" accessGroup:nil];
    userDetails = [[User alloc]init];
    
    NSString *decodedString = [userWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSData *decodedData = [NSData dataWithBase64EncodedString:decodedString];
    
    if (decodedData) {
        
        userDetails = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    }
	if (userDetails.password.length > 0 && userDetails.email.length > 0) {
		return YES;
	}
	return NO;
}

@end
