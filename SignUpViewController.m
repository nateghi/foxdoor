//
//  SignUpViewController.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 26/12/2012.
//
//

#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>

#import "SignUpViewController.h"
#import "KeychainItemWrapper.h"
#import "User.h"

#import "MasterViewController.h"
#import "NSData+Base64.h"

#import "Reachability.h"
#import "Constants.h"


#import "LogInViewController.h"
@interface SignUpViewController ()

@property(strong, nonatomic)KeychainItemWrapper *timeStampWrapper;
@property(strong, nonatomic)KeychainItemWrapper *userWrapper;
@property(strong, nonatomic)KeychainItemWrapper *registrationWrapper;
@property(strong, nonatomic)KeychainItemWrapper *fsmWrapper;;

@property(strong, nonatomic)NSString *pushID;
@property(strong, nonatomic)NSString *udid;
@property(strong, nonatomic)NSMutableString *XAppKey;
@end




@implementation SignUpViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    //                 UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    //                 [window addSubview:controller.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [reach startNotifier];
    
    UIImage *image = [UIImage imageNamed:@"BackGround"];
    
    UIColor *color = [UIColor colorWithPatternImage:image];
	//    self.view.backgroundColor = color;
    self.firstView.backgroundColor = color;
    self.secondView.backgroundColor = color;
    self.thirdView.backgroundColor = color;
    self.fourthView.backgroundColor = color;
    self.verifyView.backgroundColor = color;
    
    self.scrollView.contentSize = CGSizeMake(1300, 568);
    self.DOBTextField.delegate = self;
    self.datePicker.hidden = YES;
    
	// Do any additional setup after loading the view.
    self.userWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"account" accessGroup:nil];
    self.timeStampWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"timeStampTest" accessGroup:nil];
    self.registrationWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"registration" accessGroup:nil];
    self.fsmWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"fsm" accessGroup:nil];
    _userDetails = [[User alloc]init];
    
    _udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    _udid = [_udid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    
    NSString *lastDateString = [self.timeStampWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy : HH-mm-ss"];
    NSDate *lastDate = [[NSDate alloc] init];
    // voila!
    lastDate = [dateFormatter dateFromString:lastDateString];
    
    NSTimeInterval gapTime = [lastDate timeIntervalSinceNow];
    
    if (gapTime < -800 || gapTime == 0) {
        
        // It should reset now
        //registraionID
        [self.registrationWrapper setObject:@"0" forKey:(__bridge id)(kSecAttrAccount)];
        
        _userDetails.registrationID = @"";
        _userDetails.password = @"";
        _userDetails.mobileNo = @"";
        _userDetails.email = @"";
        _userDetails.fullName = @"";
        _userDetails.DOB = @"";
        _userDetails.houseNo = @"";
        _userDetails.flatNo = @"";
        _userDetails.postcode = @"";
        
        [self setUserDetails:_userDetails];
        
        [self doRegister:@"0"];
        
        // User Details
        
    } else {
        
        _userDetails = [self getUserDetails];
        
        NSString *fsm = [self.fsmWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
        [self doRegister:fsm];
    }
    
}



-(void)doRegister :(NSString*)fsm {
    
    //    regState = @"0";
    if ([fsm isEqualToString:@"0"] || [fsm isEqualToString:@""]) {
        //
        [self moveTo:0];
        
    } else if([fsm isEqualToString:@"1"]){
        
        self.emailTextField.text = _userDetails.email;
        self.mobileNoTextField.text = _userDetails.mobileNo;
        
        [self moveTo:320];
        
    } else if ([fsm isEqualToString:@"2"]){
        
        self.emailTextField.text = _userDetails.email;
        self.mobileNoTextField.text = _userDetails.mobileNo;
        self.fullNameTextField.text = _userDetails.fullName;
        self.DOBTextField.text = _userDetails.DOB;
        self.houseNoTextField.text = _userDetails.houseNo;
        self.flatNoTextField.text = _userDetails.flatNo;
        self.postCodeTextField.text = _userDetails.postcode;
        
        self.mobileLabel.text = _userDetails.mobileNo;
        self.emailLabel.text = _userDetails.email;
        
        [self moveTo:1300];
    }
}

-(IBAction)Next:(id)sender{
    
	[self moveTo:320];
	self.navigationController.navigationBarHidden = YES;
	self.scrollView.center = CGPointMake(self.scrollView.center.x, self.scrollView.center.y + 100);
	return;

    if ( [self validateEmail:self.emailTextField.text]  && self.mobileNoTextField.text.length > 10) {
        
        Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        [reach startNotifier];
        
		
		[self NextWebService];
        
        
    } else if (![self validateEmail:self.emailTextField.text]  || self.mobileNoTextField.text.length < 11){
        
        NSString *message;
        
        if (![self validateEmail:self.emailTextField.text]) {
            message = @"The provided email is not valid";
        } else if(self.mobileNoTextField.text.length < 11){
            message = @"The provided mobile number is not valid";
        }
        
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Invalid"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
    
}

-(void)NextWebService{
    
    UIView *blurView = [self blurView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
		
		[self.firstView addSubview:blurView];
    });
	
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _pushID = [app deviceToken];
    
    _XAppKey = [[ _udid stringByAppendingString:_pushID]mutableCopy];
    [_XAppKey insertString:@"5" atIndex:5];
    [_XAppKey insertString:@"a" atIndex:17];
    [_XAppKey insertString:@"A" atIndex:21];
    [_XAppKey insertString:@"2" atIndex:44];
    
    
    NSString *urlString = [BASE_URL stringByAppendingString:@"Service/Service/InitiateCustomerRegistration/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *jsonDic = [NSDictionary dictionaryWithObjectsAndKeys:self.mobileNoTextField.text, @"MobileNumber", self.emailTextField.text,@"Email", _udid, @"DeviceId", _pushID, @"DeviceToken", @"1.00", @"AppVersion", @"iOS", @"Platform", nil];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
    } else {
        
//        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    }
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    [request addValue:_XAppKey forHTTPHeaderField:@"X-AppKey"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         
         NSString* responseString;
         responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
         
         if (httpResponse.statusCode == 200) {
             
             
             if ([responseString isEqualToString:@"-1"]){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [blurView removeFromSuperview];
                     self.emailTextField.text = @"";
                     self.mobileNoTextField.text = @"";
                     NSString *message = @"This mobile number already exists";
                     UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Mobile Number exists" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [messageAlert show];
                 });
                 
             } else if([responseString isEqualToString:@"-2"]){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [blurView removeFromSuperview];
                     self.emailTextField.text = @"";
                     self.mobileNoTextField.text = @"";
                     
                     NSString *message = @"This email address already exists";
                     UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Email Address exists" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [messageAlert show];
                 });
                 
             } else if([responseString isEqualToString:@"0"]){
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [blurView removeFromSuperview];
                     self.emailTextField.text = @"";
                     self.mobileNoTextField.text = @"";
                     NSString *message = @"Unknow Error, please try again later";
                     UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [messageAlert show];
                 });
                 
             }  else  {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [blurView removeFromSuperview];
                     [self.mobileNoTextField resignFirstResponder];
                     [self.passwordTextField becomeFirstResponder];
                     
                     _userDetails.email = self.emailTextField.text;
                     _userDetails.mobileNo = self.mobileNoTextField.text;
                     
                     [self setUserDetails:_userDetails];
                     
                     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                     [dateFormatter setDateFormat:@"dd-MM-yyyy : HH-mm-ss"];
                     NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
                     
                     
                     if (![responseString isEqualToString:@""]) {
                         
                         [self.registrationWrapper setObject:responseString forKey:(__bridge id)(kSecAttrAccount)];
                         
                         [self.timeStampWrapper setObject:dateString forKey:(__bridge id)(kSecAttrAccount)];
                         [self.fsmWrapper setObject:@"1" forKey:(__bridge id)(kSecAttrAccount)];
                         
                     }
                     
                     [self moveTo:320];
                     
                 });
                 
             }
             
         } else {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [blurView removeFromSuperview];
                 NSString *message = @"Unknow Error, please try again later";
                 UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [messageAlert show];
             });
             
         }
         
     }];
}

// Go to page 3
-(IBAction)NextSecond:(id)sender{
    
    // Check Password
    
    if ([self.passwordTextField.text isEqualToString:self.passwordConfirmTextField.text]) {
        
        _userDetails.password = self.passwordTextField.text;
        [self moveTo:640];
    } else {
        
        NSString *message = @"Password Error";
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Password and Password confirmation does not match" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [messageAlert show];
    }
}


-(IBAction)NextThird:(id)sender{
    
    if (self.fullNameTextField.text.length > 0 && self.DOBTextField.text.length > 0) {
        
        _userDetails.fullName = self.fullNameTextField.text;
        _userDetails.DOB = self.DOBTextField.text;
        
        [self moveTo:960];
        
    } else {
        
        NSString *message = @"";
        
        if (self.fullNameTextField.text.length == 0) {
            message = @"The name field can not be empty";
        } else {
            message = @"The Date of birth field can not be empty";
        }
        
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Empty Field"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
}

-(IBAction)Done:(id)sender{
    
    if (self.houseNoTextField.text.length > 0 && self.postCodeTextField.text.length > 0) {
        
        Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
        [reach startNotifier];
        [self DoneWebService];
        
    } else {
        
        NSString *message = @"";
        
        if (self.houseNoTextField.text.length == 0) {
            message = @"The house no field can not be empty";
            
        } else {
            message = @"The postcode field can not be empty";
        }
        
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Empty Field"
                                                               message:message
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
    
}

-(void)DoneWebService{
    UIView *blurView = [self blurView];
    [self.fourthView addSubview:blurView];
    
    NSString *registrationID = [self.registrationWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    _userDetails.houseNo = self.houseNoTextField.text;
    _userDetails.flatNo = self.flatNoTextField.text;
    _userDetails.postcode = self.postCodeTextField.text;
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _pushID = [app deviceToken];
    
    NSDictionary *customer = [NSDictionary dictionaryWithObjectsAndKeys:registrationID, @"RegistrationId", _udid, @"DeviceId",_pushID, @"DeviceToken" ,_userDetails.password, @"Password", _userDetails.fullName, @"FullName", _userDetails.DOB, @"BirthDate", _userDetails.houseNo, @"HouseNumber", _userDetails.flatNo, @"FlatNumber", _userDetails.postcode, @"PostCode" , nil];
    
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
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             
             if (httpResponse.statusCode == 200) {
                 
//                 NSString *stringData = [[NSString alloc] initWithData:jsonData
//                                                              encoding:NSUTF8StringEncoding];
                 
                 NSString* responseString;
                 responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                 
                 int responseINT = [responseString intValue];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (responseINT > 0) {
                         
                         
                         if (![responseString isEqualToString:@""]) {
                             
                             // Save it as user ID
                             [blurView removeFromSuperview];
							 
                             [self.fsmWrapper setObject:@"2" forKey:(__bridge id)(kSecAttrAccount)];
                             [self setUserDetails:_userDetails];
                             
                             self.mobileLabel.text = _userDetails.mobileNo;
                             self.emailLabel.text = _userDetails.email;
                             
                             [self.postCodeTextField resignFirstResponder];
                             [self.codeMobileTextField becomeFirstResponder];
                             [self moveTo:1300];
                             
                         }
                         
                     } else{
                         
                         [blurView removeFromSuperview];
						 
                         NSString *message = @"Unknow Error, please try again later";
                         UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error"
                                                                                message:message
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                         [messageAlert show];
                     }
                     
                     
                 });
                 
             } else {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [blurView removeFromSuperview];
                     
                     NSString *message = @"Unknow Error, please try again later";
                     UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error"
                                                                            message:message
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                     [messageAlert show];
                 });
                 
             }
             
         }];
        
    }
    
}

-(IBAction)Verify:(id)sender{
    
    
    UIView *blurView = [self blurView];
    [self.verifyView addSubview:blurView];
    
    NSString *registrationID = [self.registrationWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    _userDetails = [self getUserDetails];
    
    NSDictionary *customerVerification = [NSDictionary dictionaryWithObjectsAndKeys:registrationID, @"RegistrationId",self.codeMobileTextField.text, @"SmsCode", self.codeEmailTextField.text, @"EmailCode",  nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:customerVerification
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *urlString = [BASE_URL stringByAppendingString:@"Service/Service/RegisterCustomer/"];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    if ([NSJSONSerialization isValidJSONObject:customerVerification]) {
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             
             if (httpResponse.statusCode == 200) {
                 
                 
                 NSString* responseString;
                 responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                 
                 int responseINT = [responseString intValue];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (responseINT >  0 ) {
                         
                         _userDetails.registered = @"YES";
                         _userDetails.registrationID = responseString;
                         [self setUserDetails:_userDetails];
                         
                         [self dismissViewControllerAnimated:YES completion:^{
                             
                             
                         }];
                         
                         [self.codeEmailTextField resignFirstResponder];
                         
                         UIStoryboard *stroy = [ UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
                         UINavigationController *controller = [stroy instantiateViewControllerWithIdentifier:@"HomePage"];
                         
                         UIImage *imageBar = [UIImage imageNamed:@"statusBar"];
                         [controller.navigationBar setBackgroundImage:imageBar forBarMetrics:UIBarMetricsDefault];
                         
                         [self presentViewController:controller animated:YES completion:nil];
                         
                         
                     } else {
                         
                         [blurView removeFromSuperview];
                         NSString *message = @"Inavlid code has been entered";
                         UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Code"
                                                                                message:message
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                         [messageAlert show];
                         
                     }
                     
                 });
                 
             } else {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSString *message = @"Unknow Error, please try again later";
                     UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error"
                                                                            message:message
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                     [messageAlert show];
                 });
                 
             }
             
             
         }];
        
    }
    
}

-(void)moveTo :(int)xIndex{
    
    self.scrollView.scrollEnabled = YES;
    CGPoint point = CGPointMake(xIndex, 0);
    [self.scrollView setContentOffset:point animated:YES];
    self.scrollView.scrollEnabled = NO;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    BOOL returnBool;
    
    if (textField == self.DOBTextField) {
        [self.fullNameTextField resignFirstResponder];
        [self.emailTextField resignFirstResponder];
        [self.mobileNoTextField resignFirstResponder];
        [self.houseNoTextField resignFirstResponder];
        [self.flatNoTextField resignFirstResponder];
        [self.postCodeTextField resignFirstResponder];
        [self.codeMobileTextField resignFirstResponder];
        [self.codeEmailTextField resignFirstResponder];
        
        self.datePicker.hidden = NO;
        
        returnBool = NO;
    } else {
        self.datePicker.hidden = YES;
        returnBool = YES;
    }
    
    return returnBool;
}

- (IBAction)changeDateInLabel:(id)sender{
	//Use NSDateFormatter to write out the date in a friendly format
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	self.DOBTextField.text = [NSString stringWithFormat:@"%@",
                              [df stringFromDate:self.datePicker.date]];
}


-(IBAction)PreviousSecond:(id)sender{
    
    [self CallPrevious:0];
}
-(IBAction)PreviousThird:(id)sender{
    
    [self CallPrevious:320];
}
-(IBAction)PreviousFourth:(id)sender{
    
    [self CallPrevious:640];
}
-(IBAction)PreviousFifth:(id)sender{
    
    [self CallPrevious:960];
}

-(void)CallPrevious :(int)x{
    
    self.scrollView.scrollEnabled = YES;
    CGPoint point = CGPointMake(x, 0);
    [self.scrollView setContentOffset:point animated:YES];
    self.scrollView.scrollEnabled = NO;
}


- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        
    }
    else
    {
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Connectivity Problem"
                                                               message:@"You need to connect your mobile to 3G or WiFi"
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
        [messageAlert show];
    }
}

-(User*)getUserDetails{
    
    User *user = [[User alloc]init];
    
    NSString *decodedString = [self.userWrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    NSData *decodedData = [NSData dataWithBase64EncodedString:decodedString];
    
    if (decodedData) {
        
        user = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    }
    
    return user;
}

-(void)setUserDetails:(User *)userDetails{
    
    NSData *data = [ NSKeyedArchiver archivedDataWithRootObject:userDetails];
    
    NSString *encodedString= [data base64EncodedString];
    [self.userWrapper setObject:encodedString forKey:(__bridge id)(kSecAttrAccount)];
}

-(UIView*)blurView{
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(130, 130, 60, 60)];
    
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    
    UILabel *blurView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
    blurView.backgroundColor = [UIColor blackColor];
    [blurView addSubview:indicator];
    blurView.alpha = 0.4;
    
    return blurView;
    
}

@end

/*
 
 , @"no", @"fullName" ,@"no", @"DOB", @"no", @"houseNo", @"no", @"flatNo", @"no", @"postcode", @"no", @"mobileUDID", @"no", @"mobilePushID" ,@"no", @"verified", @"no", @"emailCode", @"no", @"mobileCode", @"no", @"version"
 
 [customer setValue:self.emailTextField.text forKey:@"email"];
 [customer setValue:self.mobileNoTextField.text forKey:@"mobileNo"];
 
 [customer setValue:self.fullNameTextField.text forKey:@"fullName"];
 [customer setValue:self.DOBTextField.text forKey:@"dob"];
 
 [customer setValue:self.houseNoTextField.text forKey:@"houseNo"];
 [customer setValue:self.flatNoTextField.text forKey:@"flatNo"];
 [customer setValue:self.postCodeTextField.text forKey:@"postcode"];
 
 [customer setValue:@"no" forKey:@"mobileUDID"];
 [customer setValue:@"no" forKey:@"mobilePushID"];
 
 
 [customer setValue:@"no" forKey:@"verified"];
 [customer setValue:@"test" forKey:@"emailCode"];
 [customer setValue:@"test" forKey:@"mobileCode"];
 [customer setValue:@"version 1" forKey:@"version"];
 
 */
