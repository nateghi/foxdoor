//
//  SignUp2ViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUp2ViewController.h"

@interface SignUp2ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *PasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *ConfirmTextField;

@end

@implementation SignUp2ViewController

@synthesize PasswordTextField;
@synthesize ConfirmTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if (![PasswordTextField.text isEqualToString:ConfirmTextField.text]) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Passwords doesn't match.\nPlease Try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	
	if (!PasswordTextField.text.length  > 0) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Passwords Can't be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	[[[SignUpManager Manager] User] setPassword:PasswordTextField.text];
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - UI text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == PasswordTextField) {
		[PasswordTextField resignFirstResponder];
		[ConfirmTextField becomeFirstResponder];
	}
	if (textField == ConfirmTextField) {
		[self performSegueWithIdentifier:@"SignUp2to3" sender:self];
	}
	return YES;
}

@end
