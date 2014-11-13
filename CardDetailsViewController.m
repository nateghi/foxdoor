//
//  CardPaymentViewController.m
//  AirCash
//
//  Created by Younes Nouri Soltan on 17/02/2013.
//
//

#import "CardDetailsViewController.h"
#import "Card.h"
#import <QuartzCore/QuartzCore.h>

#import "KeychainItemWrapper.h"
#import "NSData+Base64.h"


@interface CardDetailsViewController ()

@end

@implementation CardDetailsViewController

@synthesize cards, index;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"BackGround"];
    UIColor *color = [UIColor colorWithPatternImage:image];
    self.view.backgroundColor = color;
    
    UIImage *imageHeader = [UIImage imageNamed:@"header2.png"];
    UIColor *colorHeader = [UIColor colorWithPatternImage:imageHeader];
    self.header.backgroundColor = colorHeader;
    
    self.cardDetails.layer.cornerRadius = 10;
    self.cardDetails.layer.borderWidth = 3;
    self.cardDetails.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.cardDetails.lineBreakMode = 3 ;
    
    NSMutableDictionary *card = [self.cards objectAtIndex:self.index];
    
    NSString *cardTypeString = [card valueForKey:@"cardType"];
    if ([cardTypeString isEqualToString:@"MC"]) {
        cardTypeString = @"Master";
    } else if([cardTypeString isEqualToString:@"VISA"]){
        cardTypeString = @"Visa";
    } else {
        cardTypeString = @"American Express";
    }
    
    UILabel *cardTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 30, 250, 30)];
    cardTypeLabel.textColor = [UIColor whiteColor];
    cardTypeLabel.textAlignment = NSTextAlignmentCenter;
    cardTypeLabel.text = cardTypeString;
    
//    cardString = [cardString stringByAppendingString:@"\n\n"];
    UILabel *cardNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 280, 30)];
    cardNumberLabel.textColor = [UIColor whiteColor];
    cardNumberLabel.text = [@"Card Number: " stringByAppendingString:[card valueForKey:@"cardNumber"]];
    
    UILabel *cardExpriaryDate = [[UILabel alloc]initWithFrame:CGRectMake(20, 120, 200, 30)];
    cardExpriaryDate.textColor = [UIColor whiteColor];
    cardExpriaryDate.text = [NSString stringWithFormat:@"Expiry Date: %@ / %@", card[@"expirationMonth"], card[@"expirationYear"]];

    [self.cardDetails addSubview:cardTypeLabel];
    [self.cardDetails addSubview:cardNumberLabel];
    [self.cardDetails addSubview:cardExpriaryDate];
    
}

-(IBAction)deleteCard:(id)sender{
    
    [self.cards removeObjectAtIndex:self.index];
    
    KeychainItemWrapper *cardsWrapper = [[KeychainItemWrapper alloc]initWithIdentifier:@"cardsTest" accessGroup:nil];
    NSString *encodedString= [[NSKeyedArchiver archivedDataWithRootObject:self.cards] base64EncodedString];
    [cardsWrapper setObject:encodedString forKey:(__bridge id)(kSecValueData)];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
