//
//  CardsViewController.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 23/12/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CardsManageViewController.h"
#import "CardsViewController.h"

@class CardDetailsViewController;

@interface CardManageViewController : CardsViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate>

@property(strong, nonatomic)UITableView *tableView;

@property(strong, nonatomic) CardDetailsViewController *cardDetailsViewController;

-(IBAction)dismiss:(id)sender;


@end
