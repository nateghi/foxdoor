//
//  RootViewController.m
//  FoxDoor
//
//  Created by Amir Abbas on 16/7/14.
//  Copyright (c) 2014 Younes Nouri Soltan. All rights reserved.
//

#import "RootViewController.h"
#import "LoginManager.h"
#import "KKPasscodeLock.h"

@interface RootViewController ()<KKPasscodeViewControllerDelegate>
{
	LoginManager * manager;
}
@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//	manager = [LoginManager new];
	//	[manager beginAutoLogin];
	if ([[KKPasscodeLock sharedLock] isPasscodeRequired]) {
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
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[self.navigationController setNavigationBarHidden:NO];
}

@end
