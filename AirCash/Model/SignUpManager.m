//
//  SignUpManager.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUpManager.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>

#import "SignUpViewController.h"
#import "KeychainItemWrapper.h"
#import "User.h"

#import "MasterViewController.h"
#import "NSData+Base64.h"

#import "Reachability.h"
#import "Constants.h"
@interface SignUpManager()
{
	NSString * registerationID;
}

@property(strong, nonatomic)KeychainItemWrapper *timeStampWrapper;
@property(strong, nonatomic)KeychainItemWrapper *userWrapper;
@property(strong, nonatomic)KeychainItemWrapper *registrationWrapper;
@property(strong, nonatomic)KeychainItemWrapper *fsmWrapper;;

@property(strong, nonatomic)NSString *pushID;
@property(strong, nonatomic)NSMutableString *XAppKey;

@end

@implementation SignUpManager

@synthesize User;
@synthesize Delegate;

+(instancetype) Manager
{
	static SignUpManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
	
	if (self = [super init])
	{
		self.User = [User new];
	}
	return self;
}

- (void)initialSignUp
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _pushID = [app deviceToken]?[app deviceToken]:@"";
    self.User.UUID = [[NSUUID UUID] UUIDString];
	
    _XAppKey = [[self.User.UUID stringByAppendingString:_pushID] mutableCopy];
    [_XAppKey insertString:@"5" atIndex:5];
    [_XAppKey insertString:@"a" atIndex:17];
    [_XAppKey insertString:@"A" atIndex:21];
    [_XAppKey insertString:@"2" atIndex:44];
    
    
    NSString *urlString = [BASE_URL stringByAppendingString:@"Service/Service/InitiateCustomerRegistration/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:
							 self.User.mobileNo, @"MobileNumber",
							 self.User.email, @"Email",
							 self.User.UUID, @"DeviceId",
							 _pushID?_pushID:@"", @"DeviceToken",
							 [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] , @"AppVersion",
							 @"iOS", @"Platform",
							 nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request addValue:_XAppKey forHTTPHeaderField:@"X-AppKey"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[NSUUID UUID] UUIDString];
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         
         NSString* responseString;
         responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
         
         if (httpResponse.statusCode == 200) {
             
             
             if ([responseString isEqualToString:@"-1"]){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
					 [Delegate failedPreRegisterWithMessage:@"This mobile number already exists"];
                 });
                 
             } else if([responseString isEqualToString:@"-2"]){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
					 [Delegate failedPreRegisterWithMessage:@"This email address already exists"];
                 });
                 
             } else if([responseString isEqualToString:@"0"]){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
					 [Delegate failedPreRegisterWithMessage:@"Unknow Error, please try again later"];
                 });
                 
             }  else  {
                 
				 [self setUserDetails:self.User];
				 
				 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				 [dateFormatter setDateFormat:@"dd-MM-yyyy : HH-mm-ss"];
				 NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
				 
				 
				 if (![responseString isEqualToString:@""]) {
					 
					 [self.registrationWrapper setObject:responseString forKey:(__bridge id)(kSecAttrAccount)];
					 registerationID = responseString;
					 [self.timeStampWrapper setObject:dateString forKey:(__bridge id)(kSecAttrAccount)];
					 [self.fsmWrapper setObject:@"1" forKey:(__bridge id)(kSecAttrAccount)];
				 }
				 [Delegate successfulPreRegister];
             }
         } else {
			 [Delegate failedPreRegisterWithMessage:@"Unknow Error, please try again later"];
         }
     }];
}


- (void)finishSignUp
{
	[self sendDataToServerToConfirmRegisteration];
}

- (void)sendDataToServerToConfirmRegisteration
{
	
	//    NSString *registrationID = [self.registrationWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
	
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _pushID = [app deviceToken];
    
    NSDictionary *customer = [NSDictionary dictionaryWithObjectsAndKeys:registerationID, @"RegistrationId", self.User.UUID, @"DeviceId",_pushID, @"DeviceToken" ,self.User.password, @"Password", self.User.fullName, @"FullName", self.User.DOB, @"BirthDate", self.User.houseNo, @"HouseNumber", self.User.flatNo, @"FlatNumber", self.User.postcode, @"PostCode" , nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:customer
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
    } else {
        
//        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *urlString =[ BASE_URL stringByAppendingString: @"Service/Service/UpdateCustomerRegistration/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //[request addValue:@"4172524890733923" forHTTPHeaderField:@"X-AppKey"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    if ([NSJSONSerialization isValidJSONObject:customer]) {
        
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
			 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//			 NSString * strResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			          
             if (httpResponse.statusCode == 200) {
                 
//                 NSString *stringData = [[NSString alloc] initWithData:jsonData
//                                                              encoding:NSUTF8StringEncoding];
                 
                 NSString* responseString;
                 responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                 
                 int responseINT = [responseString intValue];
                 
                 
				 if (responseINT > 0) {
					 if (![responseString isEqualToString:@""]) {
						 [Delegate successfulRegister];
					 }
				 } else{
					 [Delegate failedRegister];
				 }
             } else {
                 [Delegate failedRegister];
				 
				 NSString *message = @"Unknow Error, please try again later";
				 UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error"
																		message:message
																	   delegate:nil
															  cancelButtonTitle:@"OK"
															  otherButtonTitles:nil];
				 [messageAlert show];
				 
			 }
			 
         }];
		
	}
}

-(void)setUserDetails:(User *)userDetails{
    
    NSData *data = [ NSKeyedArchiver archivedDataWithRootObject:userDetails];
    
    NSString *encodedString= [data base64EncodedString];
    [self.userWrapper setObject:encodedString forKey:(__bridge id)(kSecAttrAccount)];
}

- (void)verifySmsCode:(NSString *)smsCode EmailCode:(NSString *)emailCode
{
	NSDictionary *customer = @{@"RegistrationId":registerationID, @"SmsCode":smsCode, @"EmailCode":emailCode};
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:customer
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
    } else {
        
//        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *urlString =[ BASE_URL stringByAppendingString: @"Service/Service/RegisterCustomer/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //[request addValue:@"4172524890733923" forHTTPHeaderField:@"X-AppKey"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    if ([NSJSONSerialization isValidJSONObject:customer]) {
        
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
			 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//			 NSString * strResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
			 
             if (httpResponse.statusCode == 200) {
				 NSString* responseString;
                 responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				 
				 int responseINT = [responseString intValue];
				 if (responseINT > 0) {
					 [self.fsmWrapper setObject:@"2" forKey:(__bridge id)(kSecAttrAccount)];
					 [self.Delegate codesHasBeenVerified];
				 }
				 else{
					 [self.Delegate codeVerificationFailed];
				 }
			 }
		 }];
	}
}

- (void)resendVerificationCodes
{
	NSDictionary *customer = @{@"RegistrationId":registerationID,
							   @"DeviceId":self.User.UUID,
							   @"DeviceToken":_pushID};
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:customer
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
    } else {
        
//        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    
    
    NSString *urlString =[ BASE_URL stringByAppendingString: @"Service/Service/ResendSmsValidationCode/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //[request addValue:@"4172524890733923" forHTTPHeaderField:@"X-AppKey"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    
    if ([NSJSONSerialization isValidJSONObject:customer]) {
        
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
			 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//			 NSString * strResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
             if (httpResponse.statusCode == 200) {
				 NSString* responseString;
                 responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
				 
				 int responseINT = [responseString intValue];
				 if (responseINT > 0) {
					 [Delegate smsCodeHasBeenSent];
				 }
				 else{
					 [Delegate failedToSendSMSCode];
				 }
			 }
		 }];
	}
}

@end
