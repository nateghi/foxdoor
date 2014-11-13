//
//  MasterViewController.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 14/04/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import "SuperViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "KKPasscodeSettingsViewController.h"

#import "KKPasscodeViewController.h"

@class PaymentDetailViewController;

#import <CoreData/CoreData.h>


@interface MasterViewController : SuperViewController < KKPasscodeViewControllerDelegate, KKPasscodeSettingsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) PaymentDetailViewController *paymentDetailViewController;


@property(strong, nonatomic)NSMutableArray *payments;
@property(assign, nonatomic)int pointer;

@property(strong, nonatomic)IBOutlet UIButton *settingButton;


@property(strong, nonatomic)IBOutlet UITableView *tableView;

- (IBAction)showMenu:(UIButton *)sender;



-(IBAction)settings:(id)sender;

-(IBAction)refresh:(id)sender;
-(IBAction)card:(id)sender;



@end
