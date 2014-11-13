//
//  SignUp4ViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUp4ViewController.h"

@interface SignUp4ViewController ()
{
	UIView *  blurView;
	BOOL canPerformSegue;
}
@property (weak, nonatomic) IBOutlet UITextField *HouseNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *FlatNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *PostCodeTextField;

@end

@implementation SignUp4ViewController

@synthesize HouseNoTextField;
@synthesize FlatNoTextField;
@synthesize PostCodeTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[[SignUpManager Manager] setDelegate:self];
	canPerformSegue = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)doneButtonTapped:(UIButton *)sender
{
	if (HouseNoTextField.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"House No can't be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return;
	}
	if (PostCodeTextField.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Post Code can't be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return;
	}
	[[[SignUpManager Manager] User] setHouseNo:HouseNoTextField.text];
	[[[SignUpManager Manager] User] setPostcode:PostCodeTextField.text];
	[[[SignUpManager Manager] User] setFlatNo:FlatNoTextField.text];
	[[SignUpManager Manager] finishSignUp];
	
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

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	return canPerformSegue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - sign Up Delegate

- (void)failedRegister
{
	[blurView removeFromSuperview];
	blurView = nil;
	
	NSString *message = @"Unknow Error, please try again later";
	UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Unkown Error"
														   message:message
														  delegate:nil
												 cancelButtonTitle:@"OK"
												 otherButtonTitles:nil];
	[messageAlert show];
}

- (void)successfulRegister
{
	[blurView removeFromSuperview];
	blurView = nil;
	canPerformSegue = YES;
	[self performSegueWithIdentifier:@"signup45" sender:self];
}

#pragma mark - UI text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == HouseNoTextField) {
		[HouseNoTextField resignFirstResponder];
		[FlatNoTextField becomeFirstResponder];
	}
	if (textField == FlatNoTextField) {
		[FlatNoTextField resignFirstResponder];
		[PostCodeTextField resignFirstResponder];
	}
	if (textField == PostCodeTextField) {
		[self performSegueWithIdentifier:@"signup45" sender:self];
	}
	return YES;
}

@end
