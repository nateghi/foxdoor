//
//  AddCardViewController.h
//  AirCash
//
//  Created by Spargonet on 29/10/2013.
//  Copyright (c) 2013 Younes Nouri Soltan. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RadioButton.h"
#import "NIDropDown.h"

#import "Card.h"
#import "SuperViewController.h"


@interface CardsViewController : SuperViewController <UITextFieldDelegate, UIPickerViewDelegate, NIDropDownDelegate>{
    
    NIDropDown *dropDown;

}

@property(strong, nonatomic)IBOutlet UIView *view1;
@property(strong, nonatomic)IBOutlet UIView *view2;

@property(strong, nonatomic)Card *card;
@property(strong, nonatomic)NSMutableArray *cards;

@property (retain, nonatomic) IBOutlet UIButton *btnSelect;

- (void)insetCard;
- (IBAction)closeView:(id)sender;
-(IBAction)nextPage:(id)sender;
-(IBAction)PreviousPage:(id)sender;
-(IBAction)Done:(id)sender;


@property(nonatomic,weak)UIButton *selectBtn;

- (IBAction)selectClicked:(id)sender;

-(void)rel;

@end
