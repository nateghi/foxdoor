//
//  SignUp3ViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUp3ViewController.h"

@interface SignUp3ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *WhiteView;
@property (weak, nonatomic) IBOutlet UITextField *FullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *BirthDayTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerView;

@end

@implementation SignUp3ViewController

@synthesize FullNameTextField;
@synthesize BirthDayTextField;
@synthesize DatePickerView;
@synthesize WhiteView;

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
	[DatePickerView setMaximumDate:[NSDate date]];
	[DatePickerView setDatePickerMode:UIDatePickerModeDate];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if (FullNameTextField.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Name can't be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	if (BirthDayTextField.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Birthday can't be empty!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return NO;
	}
	[[[SignUpManager Manager] User] setFullName:FullNameTextField.text];
	[[[SignUpManager Manager] User] setDOB:BirthDayTextField.text];
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - Text Field Delegate 

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (textField == BirthDayTextField) {
		[self.view endEditing:NO];
		
		[UIView animateWithDuration:.5 animations:^{
			[WhiteView setHidden:NO];
		}];
		[self datePickerValueChanged:DatePickerView];
		return NO;
	}
	else{
		[UIView animateWithDuration:.5 animations:^{
			[WhiteView setHidden:YES];
		}];
	}
	return YES;
}

- (IBAction)datePickerValueChanged:(id)sender
{
	NSDateFormatter * formatter = [NSDateFormatter new];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[BirthDayTextField setText:[formatter stringFromDate:DatePickerView.date]];
}

#pragma mark - UI text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == FullNameTextField) {
		[FullNameTextField resignFirstResponder];
		[BirthDayTextField becomeFirstResponder];
	}
	if (textField == BirthDayTextField) {
		[self performSegueWithIdentifier:@"SignUp3to4" sender:self];
	}
	return YES;
}

@end
