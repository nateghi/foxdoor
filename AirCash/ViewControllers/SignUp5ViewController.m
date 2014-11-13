//
//  SignUp5ViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/8/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUp5ViewController.h"
#import "SignUpManager.h"

@interface SignUp5ViewController ()<SignUpDelegate>
{
	UIView * blurView;
}
@property (weak, nonatomic) IBOutlet UITextField *SMSCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *EmailCodeTextField;


@end

@implementation SignUp5ViewController

@synthesize SMSCodeTextField;
@synthesize EmailCodeTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[SignUpManager Manager] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)VerifyCode:(id)sender {
	if (SMSCodeTextField.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:nil message:@"Please enter sms code that has been sent to you" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
	}
	if (EmailCodeTextField.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:nil message:@"Please enter email code that has been sent to your address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
	}
	[[SignUpManager Manager]
	 verifySmsCode:[SMSCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
	 EmailCode:[EmailCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	[self showInidcator];
}

- (IBAction)resendSMSCode:(id)sender {
	[self showInidcator];
	[[SignUpManager Manager] resendVerificationCodes];
}

#pragma mark - Sign Up Manager Delegate

- (void)codesHasBeenVerified
{
	[self removeIndicator];
	[[[UIAlertView alloc] initWithTitle:nil message:@"You have been registered successfully!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
	
	UIStoryboard *stroy = [ UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
	UINavigationController *controller = [stroy instantiateViewControllerWithIdentifier:@"HomePage"];
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)codeVerificationFailed
{
	[self removeIndicator];
	[[[UIAlertView alloc] initWithTitle:nil message:@"We can not verify the code that you entered" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)smsCodeHasBeenSent
{
	[self removeIndicator];
	[[[UIAlertView alloc] initWithTitle:nil message:@"SMS Code has been resent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)failedToSendSMSCode
{
	[self removeIndicator];
	[[[UIAlertView alloc] initWithTitle:nil message:@"It seems a little difficulty to resend sms code!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)showInidcator
{
	blurView = nil;
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[indicator startAnimating];
	
	UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 320, 100)];
	[label setText:@"Please wait!"];
	[label setTextColor:[UIColor whiteColor]];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setFont:[UIFont systemFontOfSize:30]];
	
	blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	blurView.backgroundColor = [UIColor blackColor];
	blurView.alpha = 0.8;
	[blurView addSubview:indicator];
	[blurView addSubview:label];
	[indicator setCenter:blurView.center];
	
	[self.view addSubview:blurView];
	[self.view bringSubviewToFront:blurView];
}

- (void)removeIndicator
{
	[blurView removeFromSuperview];
	blurView = nil;
}

#pragma mark - UI text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == SMSCodeTextField) {
		[SMSCodeTextField resignFirstResponder];
		[EmailCodeTextField becomeFirstResponder];
	}
	if (textField == EmailCodeTextField) {
		[self VerifyCode:self];
	}
	return YES;
}

@end
