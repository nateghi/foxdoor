//
//  SignUp1ViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUp1ViewController.h"
#import "Validations.h"

@interface SignUp1ViewController ()<SignUpDelegate, UITextFieldDelegate>
{
	UIView *  blurView;
	BOOL canSegue;
}
@property (weak, nonatomic) IBOutlet UITextField *EmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *MobileNumberTextField;

@end

@implementation SignUp1ViewController

@synthesize EmailTextField;
@synthesize MobileNumberTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[SignUpManager Manager] setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	BOOL mailValidation = [Validations CanValidateEmailFormat:[EmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	BOOL numberValidation = [Validations CanValidatePnoeNumber:[MobileNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	if (!mailValidation) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Email format is not correct!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	if (!numberValidation) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Phone number is not correct!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	if (canSegue) {
		return YES;
	}
	[[[SignUpManager Manager] User] setEmail:[EmailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[[[SignUpManager Manager] User] setMobileNo:[MobileNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[[SignUpManager Manager] initialSignUp];
	
	
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
	
	
	return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - Sign up delegate

- (void)failedPreRegisterWithMessage:(NSString *)message
{
	[blurView removeFromSuperview];
	blurView = nil;
	
	UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Error"
														   message:message
														  delegate:nil
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
	[messageAlert show];

}

- (void)successfulPreRegister
{
	[blurView removeFromSuperview];
	blurView = nil;
	canSegue = YES;
	[self performSegueWithIdentifier:@"SignUp1to2" sender:self];
}

#pragma mark - UI text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == EmailTextField) {
		[EmailTextField resignFirstResponder];
		[MobileNumberTextField becomeFirstResponder];
	}
	if (textField == MobileNumberTextField) {
		[self performSegueWithIdentifier:@"SignUp1to2" sender:self];
	}
	return YES;
}

@end
