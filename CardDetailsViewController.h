//
//  CardPaymentViewController.h
//  AirCash
//
//  Created by Younes Nouri Soltan on 17/02/2013.
//
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
@class Card;

@interface CardDetailsViewController : SuperViewController

@property(strong, nonatomic) NSMutableArray *cards;
@property(assign, nonatomic) NSInteger index;

@property(strong, nonatomic) IBOutlet UILabel *cardDetails;
@property(strong, nonatomic) IBOutlet UILabel *header;

-(IBAction)deleteCard:(id)sender;

@end
