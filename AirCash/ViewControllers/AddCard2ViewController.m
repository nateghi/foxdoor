//
//  AddCard2ViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "AddCard2ViewController.h"

@interface AddCard2ViewController ()<CardRegisterationDelegate>

@property (weak, nonatomic) IBOutlet UITextField *HouseNumber;
@property (weak, nonatomic) IBOutlet UITextField *PostCode;
@property (weak, nonatomic) IBOutlet UITextField *StreetName;

@end

@implementation AddCard2ViewController

@synthesize HouseNumber, PostCode, StreetName, registerationManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.navigationItem setHidesBackButton:YES];
	UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoard:)];
    [self.view addGestureRecognizer:tap];
	
	[registerationManager setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissKeyBoard:(id)sender
{
	[self.view endEditing:NO];
}

- (IBAction)tappedAddCard:(id)sender {
	if (HouseNumber.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:nil message:@"House number is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return;
	}
	if (PostCode.text.length < 1) {
		[[[UIAlertView alloc] initWithTitle:nil message:@"Post code is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
		return;
	}
	

	[registerationManager finalizeRegisterationWithHouseNumberOrName:HouseNumber.text postCode:PostCode.text streetName:StreetName.text];
}

- (IBAction)tappedPrevious:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Registeration Delegate

- (void)registeredSuccessfully
{
	[self dismissViewControllerAnimated:YES completion:nil];
//	UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
//	UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"cardManage"];
//	[self presentViewController:vc animated:YES completion:nil];
}

- (void)registerationFailedWithError:(NSString *)error
{
	[[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
