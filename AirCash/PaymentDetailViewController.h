//
//  DetailViewController.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 21/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "Card.h"
#import "RNGridMenu.h"
#import "CardsViewController.h"



@interface PaymentDetailViewController : CardsViewController <UISplitViewControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, RNGridMenuDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *payments;
@property (assign, nonatomic) int pointer;
@property (assign, nonatomic) int cardPointer;


@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *header;

@property(strong, nonatomic) MasterViewController *master;


@property(strong, nonatomic)Card *card;


-(IBAction)payNow:(id)sender;
-(IBAction)proceed:(id)sender;
-(IBAction)reject:(id)sender;


@end
