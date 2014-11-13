//
//  SignUpMasterViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "SignUpMasterViewController.h"

@interface SignUpMasterViewController ()

@end

@implementation SignUpMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"statusBar"] forBarMetrics:UIBarMetricsDefault];
	
	[self.navigationItem setHidesBackButton:YES];
	
	UIBarButtonItem * signIn = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStylePlain target:self action:@selector(SignInTapped)];
	[signIn setTintColor:[UIColor whiteColor]];
	[self.navigationItem setRightBarButtonItem:signIn];
	UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoar:)];
	[self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)PreviousButtonTapped:(UIButton *)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)SignInTapped
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)dismissKeyBoar:(id)sender
{
    [self.view endEditing:NO];
}

@end
