//
//  LogInViewController.m
//  FoxDoor
//
//  Created by Spargonet on 02/01/2014.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "LogInViewController.h"
#import "Constants.h"
#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "KeychainItemWrapper.h"
#import "LoginManager.h"
#import "KKPasscodeLock.h"


@interface LogInViewController ()<LoginDelegate, UITextFieldDelegate, KKPasscodeViewControllerDelegate>
{
	UIView * blurView;
	BOOL hasCheckedPassword;
}

@property(nonatomic, strong)IBOutlet UITextField *userNameTextField;
@property(nonatomic, strong)IBOutlet UITextField *passwordTextField;
@property(nonatomic, strong)IBOutlet UIButton *logInButton;

@property LoginManager * MyLoginManager;
@property(assign, nonatomic)BOOL autoLogIn;

@end

@implementation LogInViewController

@synthesize MyLoginManager;
@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize logInButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyBoard:)];
    [self.view addGestureRecognizer:tap];
	[self.navigationItem setHidesBackButton:YES];
	hasCheckedPassword = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"statusBar"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//	manager = [LoginManager new];
	//	[manager beginAutoLogin];
	if ([[KKPasscodeLock sharedLock] isPasscodeRequired] && !hasCheckedPassword) {
		hasCheckedPassword = YES;
        KKPasscodeViewController *vc = [[KKPasscodeViewController alloc] initWithNibName:nil bundle:nil];
        vc.mode = KKPasscodeModeEnter;
        vc.delegate = self;
        
		dispatch_async(dispatch_get_main_queue(),^ {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
			//            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			//                nav.modalPresentationStyle = UIModalPresentationFormSheet;
			//                nav.navigationBar.barStyle = UIBarStyleBlack;
			//                nav.navigationBar.opaque = NO;
			//            } else {
			//                nav.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
			//                nav.navigationBar.translucent = self.navigationController.navigationBar.translucent;
			//                nav.navigationBar.opaque = self.navigationController.navigationBar.opaque;
			//                nav.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
			//            }
            
            [self.navigationController presentViewController:nav animated:NO completion:nil];
        });
    }
	else
	{
		[self beginAutoLogin];
	}
}

-(IBAction)logIn:(id)sender{
	NSString * userName = [userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSString * password = passwordTextField.text;
	[MyLoginManager authenticateWithUserName:userName password:password];
	[self dismissKeyBoard:self];
	
	[self showIndicator];
}

-(void)dismissKeyBoard:(id)sender
{
    [self.view endEditing:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login Delegate

- (void)Authenticated
{
	[blurView removeFromSuperview];
	blurView = nil;
	UIStoryboard *stroy = [ UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:[NSBundle mainBundle]];
	UINavigationController *controller = [stroy instantiateViewControllerWithIdentifier:@"HomePage"];
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)NotAuthenticatedWithType:(AuthenticationProblems)type
{
	UIAlertView *messageAlert;
	if (type == UnknownProblem) {
		messageAlert = [[UIAlertView alloc] initWithTitle:@"Unknown Error"
												  message:@"Please try again later"
												 delegate:nil
										cancelButtonTitle:@"OK"
										otherButtonTitles:nil];
	}
	if (type == UserNameOrPasswordProblem) {
		messageAlert = [[UIAlertView alloc] initWithTitle:@"Invalid User"
												  message:@"User name or password is incorrect"
												 delegate:nil
										cancelButtonTitle:@"OK"
										otherButtonTitles:nil];
	}
	[messageAlert show];
	
	[blurView removeFromSuperview];
	blurView = nil;
}

- (void)showIndicator
{
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

#pragma mark - UI text field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == userNameTextField) {
		[userNameTextField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	}
	if (textField == passwordTextField) {
		[self logIn:logInButton];
	}
	return YES;
}



- (void)shouldEraseApplicationData:(KKPasscodeViewController*)viewController
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times. All account data in this app has been deleted." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)didPasscodeEnteredIncorrectly:(KKPasscodeViewController*)viewController
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You have entered an incorrect passcode too many times." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)didPasscodeEnteredCorrectly:(KKPasscodeViewController*)viewController;
{
	[self beginAutoLogin];
}

- (void)beginAutoLogin
{
	if (!MyLoginManager) {
		MyLoginManager = [LoginManager new];
		[MyLoginManager setDelegate:self];
		if ([MyLoginManager isUserRegistered]) {
			[self showIndicator];
			[MyLoginManager beginAutoLogin];
		}
	}
}

@end
